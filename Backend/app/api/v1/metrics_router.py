import asyncio
from typing import Optional

from fastapi import (
    APIRouter,
    Query,
    status,
    Depends,
    Path,
    WebSocket,
    WebSocketDisconnect,
)
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.core.DB.database import get_db
from app.core.websocket_manager import ConnectionManager
from app.schemas.base_schema import BaseResponse
from app.services.metrics_service import (
    get_server_metrics_service,
    get_timeseries_service,
    get_model_per_inference_stats_service,
    get_model_per_inference_latency_service,
    get_dashboard_models_list_service,
)

metrics_router = APIRouter(prefix="/dashboard", tags=["Metrics"])


# ============================================================
# 1. 서버 리소스 메트릭 (CPU/GPU) - HTTP + WebSocket
# ============================================================

SERVER_METRICS_POLL_INTERVAL_SEC = 1

server_ws_manager = ConnectionManager()
_server_metrics_last_payload: Optional[dict] = None
_server_metrics_poll_task: Optional[asyncio.Task] = None


@metrics_router.get(
    "/server/metrics",
    response_model=BaseResponse,
    status_code=status.HTTP_200_OK,
)
async def get_server_metrics():
    """서버 리소스(CPU/GPU) 현재 스냅샷 조회 (HTTP)."""
    return await get_server_metrics_service()


async def _poll_server_metrics_and_broadcast() -> None:
    """
    - 주기적으로 get_server_metrics_service() 호출
    - 연결된 클라이언트가 있을 때만 동작
    - 직전 payload와 다를 때만 broadcast
    """
    global _server_metrics_last_payload

    while True:
        try:
            # 클라이언트가 없으면 그냥 대기
            if not server_ws_manager.active_connections:
                await asyncio.sleep(SERVER_METRICS_POLL_INTERVAL_SEC)
                continue

            resp = await get_server_metrics_service()
            payload = jsonable_encoder(resp)

            if payload != _server_metrics_last_payload:
                _server_metrics_last_payload = payload
                await server_ws_manager.broadcast_json(payload)

        except Exception as e:
            print(f"[server_metrics_ws] polling error: {e}")

        await asyncio.sleep(SERVER_METRICS_POLL_INTERVAL_SEC)


@metrics_router.websocket("/server/metrics/ws")
async def ws_server_metrics(websocket: WebSocket):
    """
    서버 리소스 메트릭 실시간 스트림 WebSocket.
    - 클라이언트: ws://.../dashboard/server/metrics/ws
    """
    await server_ws_manager.connect(websocket)

    global _server_metrics_poll_task
    if _server_metrics_poll_task is None or _server_metrics_poll_task.done():
        _server_metrics_poll_task = asyncio.create_task(_poll_server_metrics_and_broadcast())

    # 최신 스냅샷이 있으면 먼저 한 번 보내주기
    if _server_metrics_last_payload is not None:
        await websocket.send_json(_server_metrics_last_payload)

    try:
        # 메시지를 안 쓰더라도 receive_text()로 연결 유지
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        server_ws_manager.disconnect(websocket)
    except Exception:
        server_ws_manager.disconnect(websocket)


# ============================================================
# 2. 서버 리소스 시계열 (VRAM/RAM) - HTTP + WebSocket
# ============================================================

TIMESERIES_POLL_INTERVAL_SEC = 10

timeseries_ws_manager = ConnectionManager()
_timeseries_last_payload: Optional[dict] = None
_timeseries_poll_task: Optional[asyncio.Task] = None


@metrics_router.get("/server/timeseries")
async def get_server_timeseries(
    end: Optional[str] = Query(None, description="RFC3339(…Z) 또는 epoch 초"),
):
    """GPU/CPU 메모리 사용률 시계열 조회 (HTTP)."""
    return await get_timeseries_service(end_iso=end)


async def _poll_timeseries_and_broadcast() -> None:
    """
    - 주기적으로 get_timeseries_service() 호출 (end=None → 현재 기준 1시간)
    - 직전 payload와 비교하여 변경 시 WebSocket으로 broadcast
    """
    global _timeseries_last_payload

    while True:
        try:
            if not timeseries_ws_manager.active_connections:
                await asyncio.sleep(TIMESERIES_POLL_INTERVAL_SEC)
                continue

            resp = await get_timeseries_service(end_iso=None)
            payload = jsonable_encoder(resp)

            if payload != _timeseries_last_payload:
                _timeseries_last_payload = payload
                await timeseries_ws_manager.broadcast_json(payload)

        except Exception as e:
            print(f"[timeseries_ws] polling error: {e}")

        await asyncio.sleep(TIMESERIES_POLL_INTERVAL_SEC)


@metrics_router.websocket("/server/timeseries/ws")
async def ws_server_timeseries(websocket: WebSocket):
    """
    서버 리소스 시계열 메트릭 WebSocket.
    - 클라이언트: ws://.../dashboard/server/timeseries/ws
    """
    await timeseries_ws_manager.connect(websocket)

    global _timeseries_poll_task
    if _timeseries_poll_task is None or _timeseries_poll_task.done():
        _timeseries_poll_task = asyncio.create_task(_poll_timeseries_and_broadcast())

    # 최신 값이 있으면 먼저 한 번 전송
    if _timeseries_last_payload is not None:
        await websocket.send_json(_timeseries_last_payload)

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        timeseries_ws_manager.disconnect(websocket)
    except Exception:
        timeseries_ws_manager.disconnect(websocket)


# ============================================================
# 3. 모델 목록 / 모델 통계 / 모델 레이턴시 - HTTP
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


@metrics_router.get(
    "/model/{model_id}/latency",
    response_model=BaseResponse,
    status_code=status.HTTP_200_OK,
)
async def get_model_per_inference_latency(
    model_id: int = Path(...),
    end: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """특정 모델의 구간별 레이턴시 시계열 (HTTP)."""
    return await get_model_per_inference_latency_service(model_id, end, db)


# ============================================================
# 4. 모델 레이턴시 - WebSocket
# ============================================================

MODEL_LATENCY_POLL_INTERVAL_SEC = 5


@metrics_router.websocket("/model/{model_id}/latency/ws")
async def ws_model_latency(
    websocket: WebSocket,
    model_id: int = Path(...),
    db: Session = Depends(get_db),
):
    """
    모델 레이턴시 WebSocket.
    - 클라이언트: ws://<host>/api/v1/dashboard/model/{model_id}/latency/ws
    - 주기적으로 get_model_per_inference_latency_service() 호출 후, 변경 시 push
    """
    await websocket.accept()
    print(f"[model_latency_ws] new connection model_id={model_id}")

    last_payload: Optional[dict] = None

    try:
        while True:
            resp = await get_model_per_inference_latency_service(
                model_id=model_id,
                end_iso=None,
                db=db,
            )
            payload = jsonable_encoder(resp)

            if payload != last_payload:
                last_payload = payload
                await websocket.send_json(payload)

            await asyncio.sleep(MODEL_LATENCY_POLL_INTERVAL_SEC)

    except WebSocketDisconnect:
        print(f"[model_latency_ws] disconnected model_id={model_id}")
    except Exception as e:
        print(f"[model_latency_ws] error model_id={model_id}: {e}")
