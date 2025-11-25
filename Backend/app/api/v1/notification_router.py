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
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages

notification_router = APIRouter(prefix="/noti", tags=["Notification"])


@notification_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_inference_notification(
    page: int = Query(1, ge=1),
    size: int = Query(8, ge=1, le=100),
    db: Session = Depends(get_clickhouse_db),
):
    return get_inference_notification_service(db=db, page=page, size=size)


# Vector → FastAPI PUSH endpoint
@notification_router.post("/error-event", response_model=BaseResponse)
async def push_error_event(event: dict):
    await error_log_channel.publish(event)
    return create_response(
        CustomCode.NOTI_001.value,
        Messages.NOTIFICATION_FETCH_SUCCESS.value,
        data={"received": event},
    )


# SSE endpoint
@notification_router.get("/error-sse")
async def error_sse(db=Depends(get_clickhouse_db)):

    rows = db.execute(text("""
        SELECT toDateTime64(ts, 6) AS ts, level, error_message
        FROM logs.triton_error_logs
        ORDER BY ts DESC
        LIMIT 10
    """)).fetchall()

    history = [
        {"ts": str(r.ts), "level": r.level, "error_message": r.error_message}
        for r in rows
    ]

    async def event_stream():
        queue = error_log_channel.subscribe()

        try:
            # 최초 히스토리 전송 — BaseResponse 적용
            init_packet = create_response(
                CustomCode.NOTI_001.value,
                Messages.NOTIFICATION_FETCH_SUCCESS.value,
                data={"history": history},
            ).json()

            yield f"data: {init_packet}\n\n"

            # 실시간 + heartbeat
            while True:
                try:
                    data = await asyncio.wait_for(queue.get(), timeout=30)

                    if isinstance(data, str):
                        try:
                            data = json.loads(data)
                        except:
                            pass

                    json_str = create_response(
                        CustomCode.NOTI_001.value,
                        Messages.NOTIFICATION_FETCH_SUCCESS.value,
                        data=data,
                    ).model_dump_json()

                    yield f"data: {json_str}\n\n"

                except asyncio.TimeoutError:
                    heartbeat = create_response(
                        CustomCode.HEARTBEAT_001.value,
                        Messages.HEARTBEAT_SUCCESS.value,
                        data={"heartbeat": True},
                    ).model_dump_json()

                    yield f"data: {heartbeat}\n\n"

        except asyncio.CancelledError:
            error_log_channel.unsubscribe(queue)
            raise

    return StreamingResponse(event_stream(), media_type="text/event-stream")
