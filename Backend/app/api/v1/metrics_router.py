# app/api/v1/metrics_router.py

from typing import Dict
from fastapi import APIRouter, Path
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.core.DB.database import get_db
from app.services.metrics_service import (
    get_server_metrics_service,
    get_timeseries_service,
    get_model_per_inference_stats_service,
    get_model_per_inference_latency_service,
    get_dashboard_models_list_service,
)
from Backend.app.common.sse_polling_channel import PollingSSEChannel, sse_event_stream
from fastapi.concurrency import run_in_threadpool  # 모델 stats용 (sync -> threadpool)


metrics_router = APIRouter(prefix="/dashboard", tags=["Metrics"])

# ============================================================
# 1. 서버 리소스 메트릭 (CPU/GPU) - SSE
# ============================================================

SERVER_METRICS_POLL_INTERVAL_SEC = 5  # Triton/Prometheus 주기에 맞게 조정


async def _fetch_server_metrics():
    # BaseResponse 그대로 보냄 (프론트에서 payload.data 사용)
    return await get_server_metrics_service()


server_metrics_channel = PollingSSEChannel(
    fetch_fn=_fetch_server_metrics,
    interval_sec=SERVER_METRICS_POLL_INTERVAL_SEC,
)


@metrics_router.get("/server/metrics/stream")
async def stream_server_metrics():
    """
    서버 리소스 메트릭 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/server/metrics/stream
    - 응답: text/event-stream
    """
    return StreamingResponse(
        sse_event_stream(server_metrics_channel),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",  # nginx 사용 시 버퍼링 방지
        },
    )


# ============================================================
# 2. 서버 리소스 시계열 (VRAM/RAM) - SSE
# ============================================================

TIMESERIES_POLL_INTERVAL_SEC = 10


async def _fetch_server_timeseries():
    # end_iso=None → "현재 기준 1시간"
    return await get_timeseries_service(end_iso=None)


server_timeseries_channel = PollingSSEChannel(
    fetch_fn=_fetch_server_timeseries,
    interval_sec=TIMESERIES_POLL_INTERVAL_SEC,
)


@metrics_router.get("/server/timeseries/stream")
async def stream_server_timeseries():
    """
    서버 리소스 시계열 메트릭 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/server/timeseries/stream
    """
    return StreamingResponse(
        sse_event_stream(server_timeseries_channel),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


# ============================================================
# 3. 모델 목록 - SSE
# ============================================================

MODELS_POLL_INTERVAL_SEC = 15  # 모델 목록은 너무 자주 안 바꿔도 됨 (필요 시 조정)


async def _fetch_models_list():
    """
    Triton READY 모델 목록 + 간단 통계를 가져오는 fetch 함수.
    - 각 poll마다 DB 세션을 열고 닫는다.
    """
    db_gen = get_db()
    db: Session = next(db_gen)
    try:
        return await get_dashboard_models_list_service(db)
    finally:
        try:
            db_gen.close()
        except Exception:
            pass


models_list_channel = PollingSSEChannel(
    fetch_fn=_fetch_models_list,
    interval_sec=MODELS_POLL_INTERVAL_SEC,
)


@metrics_router.get("/models/stream")
async def stream_dashboard_models_list():
    """
    모델 목록 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/models/stream
    - 응답: text/event-stream
    """
    return StreamingResponse(
        sse_event_stream(models_list_channel),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


# ============================================================
# 4. 모델 레이턴시 - SSE (모델별 채널)
# ============================================================

MODEL_LATENCY_POLL_INTERVAL_SEC = 5

_model_latency_channels: Dict[int, PollingSSEChannel] = {}


def _get_model_latency_channel(model_id: int) -> PollingSSEChannel:
    """
    model_id 별로 SSEChannel을 lazily 생성/재사용.
    """
    if model_id in _model_latency_channels:
        return _model_latency_channels[model_id]

    async def fetch_model_latency():
        # 각 poll마다 DB 세션을 열고 닫는다.
        db_gen = get_db()
        db: Session = next(db_gen)
        try:
            return await get_model_per_inference_latency_service(
                model_id=model_id,
                end_iso=None,
                db=db,
            )
        finally:
            try:
                db_gen.close()
            except Exception:
                pass

    channel = PollingSSEChannel(
        fetch_fn=fetch_model_latency,
        interval_sec=MODEL_LATENCY_POLL_INTERVAL_SEC,
    )
    _model_latency_channels[model_id] = channel
    return channel


@metrics_router.get("/model/{model_id}/latency/stream")
async def stream_model_latency(model_id: int = Path(...)):
    """
    모델 레이턴시 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/model/{model_id}/latency/stream
    - 응답: text/event-stream
    """
    channel = _get_model_latency_channel(model_id)
    return StreamingResponse(
        sse_event_stream(channel),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


# ============================================================
# 5. 모델 통계 - SSE (모델별 채널)
# ============================================================

MODEL_STATS_POLL_INTERVAL_SEC = 10

_model_stats_channels: Dict[int, PollingSSEChannel] = {}


def _get_model_stats_channel(model_id: int) -> PollingSSEChannel:
    """
    model_id 별로 SSEChannel을 lazily 생성/재사용.
    """
    if model_id in _model_stats_channels:
        return _model_stats_channels[model_id]

    async def fetch_model_stats():
        # 각 poll마다 DB 세션을 열고 닫는다.
        db_gen = get_db()
        db: Session = next(db_gen)
        try:
            # get_model_per_inference_stats_service는 sync 함수라 threadpool로 돌려줌
            return await run_in_threadpool(
                get_model_per_inference_stats_service,
                model_id,
                db,
            )
        finally:
            try:
                db_gen.close()
            except Exception:
                pass

    channel = PollingSSEChannel(
        fetch_fn=fetch_model_stats,
        interval_sec=MODEL_STATS_POLL_INTERVAL_SEC,
    )
    _model_stats_channels[model_id] = channel
    return channel


@metrics_router.get("/model/{model_id}/stats/stream")
async def stream_model_stats(model_id: int = Path(...)):
    """
    모델 통계 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/model/{model_id}/stats/stream
    - 응답: text/event-stream
    """
    channel = _get_model_stats_channel(model_id)
    return StreamingResponse(
        sse_event_stream(channel),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )
