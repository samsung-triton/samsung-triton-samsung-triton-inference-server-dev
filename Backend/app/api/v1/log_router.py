from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.orm import Session
from fastapi.responses import StreamingResponse

from app.core.DB.database import get_db
from app.core.DB.clickhouse import get_clickhouse_db
from app.schemas.base_schema import BaseResponse
from app.schemas.log_schema import LogRequest, ModelLogRequest, ServerLogRequest

from app.services.log_service import (
    get_web_log_service,
    get_model_name_list_service,
    get_infer_logs_service,
    get_server_logs_service,
)
from app.common.sse_channels import infer_log_channel, server_log_channel


log_router = APIRouter(prefix="/logs", tags=["Log"])


@log_router.post("/web", response_model=BaseResponse)
def get_web_log(
    request: LogRequest,
    page: int = Query(1, ge=1),
    size: int = Query(30, ge=1, le=200),
    db: Session = Depends(get_db),
):
    """대시보드 웹 로그 조회"""
    return get_web_log_service(
        start_date=request.start_date,
        end_date=request.end_date,
        username=request.username,
        type=request.type,
        description=request.description,
        global_search=request.global_search,
        page=page,
        size=size,
        db=db,
    )


@log_router.get("/models", response_model=BaseResponse)
def get_model_list(db: Session = Depends(get_clickhouse_db)):
    """로그의 모델명 목록 조회"""
    return get_model_name_list_service(db)


@log_router.post("/infer", response_model=BaseResponse)
def get_infer_logs(
    request: ModelLogRequest,
    db: Session = Depends(get_clickhouse_db),
):
    """추론 로그 조회"""
    return get_infer_logs_service(
        db=db,
        model_name=request.model_name,
        start=request.start,
        end=request.end,
        level=request.level,
        cursor=request.cursor,
        request_id=request.request_id,
        global_search=request.global_search,
        limit=request.limit,
    )


@log_router.post("/server", response_model=BaseResponse)
def get_server_logs(
    request: ServerLogRequest,
    db: Session = Depends(get_clickhouse_db),
):
    """서버 로그 조회"""
    return get_server_logs_service(
        db=db,
        start=request.start,
        end=request.end,
        level=request.level,
        cursor=request.cursor,
        global_search=request.global_search,
        limit=request.limit,
    )


# ==============================
# Vector → FastAPI (Push)
# ==============================
@log_router.post("/infer-event")
async def receive_infer_event(request: Request):
    payload = await request.json()
    await infer_log_channel.publish(payload)
    return {"ok": True}


@log_router.post("/server-event")
async def receive_server_event(request: Request):
    payload = await request.json()
    await server_log_channel.publish(payload)
    return {"ok": True}


# ==============================
# Frontend → SSE Stream
# ==============================
@log_router.get("/infer/stream")
async def stream_infer_logs():
    queue = infer_log_channel.subscribe()
    return StreamingResponse(
        infer_log_channel.generator(queue),
        media_type="text/event-stream",
    )


@log_router.get("/server/stream")
async def stream_server_logs():
    queue = server_log_channel.subscribe()
    return StreamingResponse(
        server_log_channel.generator(queue),
        media_type="text/event-stream",
    )
