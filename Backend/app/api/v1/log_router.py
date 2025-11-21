from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from fastapi import status

from app.core.DB.database import get_db
from app.core.DB.clickhouse import get_clickhouse_db
from app.services.log_service import (
    get_api_log_service,
    get_model_name_list_service,
    get_model_logs_service,
    get_server_logs_service,
)
from app.schemas.base_schema import BaseResponse
from app.schemas.log_schema import LogRequest, ModelLogRequest, ServerLogRequest
from app.services.log_service import subscribe_infer_log
from fastapi.responses import StreamingResponse

log_router = APIRouter(prefix="/logs", tags=["Log"])


@log_router.post("/api", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_api_log(
    request: LogRequest,
    page: int = Query(1, ge=1, description="페이지 번호(1부터 시작)"),
    size: int = Query(30, ge=1, le=200, description="페이지당 개수 최댓감 :200"),
    db: Session = Depends(get_db),
):
    return get_api_log_service(
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


@log_router.get("/model-list")
def get_model_list(db: Session = Depends(get_clickhouse_db)):
    return get_model_name_list_service(db)


@log_router.post("/model")
def get_model_logs(
    request: ModelLogRequest,
    db: Session = Depends(get_clickhouse_db),
):
    return get_model_logs_service(
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


@log_router.post("/system")
def get_system_logs(
    request: ServerLogRequest,
    db: Session = Depends(get_clickhouse_db),
):
    return get_server_logs_service(
        db=db,
        start=request.start,
        end=request.end,
        level=request.level,
        cursor=request.cursor,
        global_search=request.global_search,
        limit=request.limit,
    )

@log_router.get("/infer/stream")
async def stream_infer_logs():
    """
    실시간 추론 로그 SSE 스트림
    """
    return StreamingResponse(
        subscribe_infer_log(),
        media_type="text/event-stream"
    )