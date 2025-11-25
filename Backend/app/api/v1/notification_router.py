from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from fastapi import status
import asyncio
import json
from sqlalchemy import text
from fastapi.responses import StreamingResponse

from app.core.DB.clickhouse import get_clickhouse_db
from app.schemas.base_schema import BaseResponse
from app.services.notification_service import get_inference_notification_service
from app.common.sse_channels import error_log_channel

notification_router = APIRouter(prefix="/noti", tags=["Notification"])


@notification_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_inference_notification(
    page: int = Query(1, ge=1, description="페이지 번호(1부터 시작)"),
    size: int = Query(8, ge=1, le=100, description="페이지당 개수"),
    db: Session = Depends(get_clickhouse_db),
):
    return get_inference_notification_service(db=db, page=page, size=size)


# Vector → FastAPI PUSH endpoint
@notification_router.post("/error-event")
async def push_error_event(event: dict):
    await error_log_channel.publish(event)
    return {"status": "ok"}


# SSE endpoint
@notification_router.get("/error-sse")
async def error_sse(db=Depends(get_clickhouse_db)):
    # 1) 최근 10개 ERROR 로그 가져오기
    rows = db.execute(text("""
        SELECT toDateTime64(ts, 6) AS ts,
                    level,
                    error_message
        FROM logs.triton_error_logs
        ORDER BY ts DESC
        LIMIT 10
    """)).fetchall()

    history = [
        {
            "ts": str(r.ts),
            "level": r.level,
            "error_message": r.error_message
        }
        for r in rows
    ]

    async def event_stream():
        # 2) SSE 채널 구독
        queue = error_log_channel.subscribe()

        try:
            # 3) 최초 연결 시 과거 히스토리 한번 전송
            init_packet = json.dumps({"history": history}, ensure_ascii=False)
            yield f"data: {init_packet}\n\n"

            # 4) 실시간 + heartbeat loop
            while True:
                try:
                    # 새 에러 로그 이벤트 대기
                    data = await asyncio.wait_for(queue.get(), timeout=30)
                    yield f"data: {data}\n\n"

                except asyncio.TimeoutError:
                    # heartbeat
                    yield 'data: {"heartbeat": true}\n\n'

        except asyncio.CancelledError:
            error_log_channel.unsubscribe(queue)
            raise

    return StreamingResponse(event_stream(), media_type="text/event-stream")
