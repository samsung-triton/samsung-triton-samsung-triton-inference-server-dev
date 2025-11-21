import asyncio
import json
from typing import Optional, Dict

from fastapi import (
    APIRouter,
    status,
    Depends,
    Path,
)
from fastapi.encoders import jsonable_encoder
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.core.DB.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.metrics_service import (
    get_server_metrics_service,
    get_timeseries_service,
    get_model_per_inference_stats_service,
    get_model_per_inference_latency_service,
    get_dashboard_models_list_service,
)
from app.core.customException import CustomHTTPException

metrics_router = APIRouter(prefix="/dashboard", tags=["Metrics"])


# ============================================================
# SSE 공통 채널 구현 (백그라운드 1회 조회 + 팬아웃)
# ============================================================


class SSEChannel:
    """
    - fetch_fn: async () -> dict (jsonable_encoder로 인코딩 가능한 객체)
    - interval_sec: polling 주기
    - subscribers: 각 클라이언트 별 asyncio.Queue[str] (JSON string)
    - poll_task: 백그라운드에서 fetch_fn을 주기적으로 호출하는 태스크
    """

    def __init__(self, fetch_fn, interval_sec: int):
        self.fetch_fn = fetch_fn
        self.interval_sec = interval_sec

        self.subscribers: set[asyncio.Queue[str]] = set()
        self._latest_payload: Optional[str] = None  # JSON string
        self._poll_task: Optional[asyncio.Task] = None
        self._lock = asyncio.Lock()

    async def ensure_polling(self):
        """
        - 첫 구독자가 붙거나, 이전 task가 끝났을 때만 poll_task 시작
        """
        async with self._lock:
            if self._poll_task is None or self._poll_task.done():
                self._poll_task = asyncio.create_task(self._poll_loop())

    async def _poll_loop(self):
        """
        - 구독자가 하나라도 있을 때만 fetch_fn을 주기적으로 호출
        - 값이 바뀌면 모든 구독자에게 전달
        """
        while self.subscribers:
            try:
                try:
                    resp = await self.fetch_fn()
                    payload_dict = jsonable_encoder(resp)
                except CustomHTTPException as e:
                    payload_dict = {"error": e.message, "code": e.code}
                except Exception as e:
                    payload_dict = {"error": str(e)}

                data_str = json.dumps(payload_dict, ensure_ascii=False)

                if data_str != self._latest_payload:
                    self._latest_payload = data_str
                    await self._broadcast(data_str)

            except Exception as e:
                # Poll 자체에서 예상치 못한 에러 발생 시 에러 이벤트 전파
                err_str = json.dumps(
                    {"error": f"polling failed: {e}"},
                    ensure_ascii=False,
                )
                await self._broadcast(err_str)

            await asyncio.sleep(self.interval_sec)

        # 구독자가 하나도 없으면 루프 종료 → 다음 ensure_polling에서 다시 시작 가능

    async def _broadcast(self, data_str: str):
        # dead subscriber가 있어도 전체 실패하지 않도록 순회
        for q in list(self.subscribers):
            try:
                await q.put(data_str)
            except Exception:
                # queue에 put 실패하는 경우는 거의 없지만, 안전하게 제거
                self.subscribers.discard(q)

    def subscribe(self) -> asyncio.Queue:
        q: asyncio.Queue[str] = asyncio.Queue()
        self.subscribers.add(q)
        return q

    def unsubscribe(self, q: asyncio.Queue):
        self.subscribers.discard(q)

    @property
    def latest_payload(self) -> Optional[str]:
        return self._latest_payload


# ============================================================
# 1. 서버 리소스 메트릭 (CPU/GPU) - SSE
# ============================================================

SERVER_METRICS_POLL_INTERVAL_SEC = 5  # Triton/Prometheus 주기에 맞게 조정


async def _fetch_server_metrics():
    # BaseResponse 그대로 보냄 (프론트에서 payload.data 사용)
    return await get_server_metrics_service()


server_metrics_channel = SSEChannel(
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
    queue = server_metrics_channel.subscribe()
    await server_metrics_channel.ensure_polling()

    async def event_generator():
        try:
            # 캐시가 있다면 바로 한 번 쏴주기
            if server_metrics_channel.latest_payload is not None:
                yield f"data: {server_metrics_channel.latest_payload}\n\n"

            while True:
                data_str = await queue.get()
                yield f"data: {data_str}\n\n"
        finally:
            server_metrics_channel.unsubscribe(queue)

    return StreamingResponse(
        event_generator(),
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


server_timeseries_channel = SSEChannel(
    fetch_fn=_fetch_server_timeseries,
    interval_sec=TIMESERIES_POLL_INTERVAL_SEC,
)


@metrics_router.get("/server/timeseries/stream")
async def stream_server_timeseries():
    """
    서버 리소스 시계열 메트릭 SSE 스트림.
    - 클라이언트: GET /api/v1/dashboard/server/timeseries/stream
    """
    queue = server_timeseries_channel.subscribe()
    await server_timeseries_channel.ensure_polling()

    async def event_generator():
        try:
            if server_timeseries_channel.latest_payload is not None:
                yield f"data: {server_timeseries_channel.latest_payload}\n\n"

            while True:
                data_str = await queue.get()
                yield f"data: {data_str}\n\n"
        finally:
            server_timeseries_channel.unsubscribe(queue)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


# ============================================================
# 3. 모델 목록 / 모델 통계 (HTTP 그대로 유지)
# ============================================================


@metrics_router.get("/models")
async def get_dashboard_models_list(db: Session = Depends(get_db)):
    """대시보드에 노출할 Triton READY 모델 목록 + 간단 통계."""
    return await get_dashboard_models_list_service(db)


@metrics_router.get(
    "/model/{model_id}/stats",
    response_model=BaseResponse,
    status_code=status.HTTP_200_OK,
)
def get_model_per_inference_stats(
    model_id: int = Path(...),
    db: Session = Depends(get_db),
):
    """특정 모델의 요청/추론 성공률, 에러 수, 평균 지연시간 등 통계 (HTTP)."""
    return get_model_per_inference_stats_service(model_id, db)


# ============================================================
# 4. 모델 레이턴시 - SSE (모델별 채널)
# ============================================================

MODEL_LATENCY_POLL_INTERVAL_SEC = 5

_model_latency_channels: Dict[int, SSEChannel] = {}


def _get_model_latency_channel(model_id: int) -> SSEChannel:
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

    channel = SSEChannel(
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
    queue = channel.subscribe()
    await channel.ensure_polling()

    async def event_generator():
        try:
            if channel.latest_payload is not None:
                yield f"data: {channel.latest_payload}\n\n"

            while True:
                data_str = await queue.get()
                yield f"data: {data_str}\n\n"
        finally:
            channel.unsubscribe(queue)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )
