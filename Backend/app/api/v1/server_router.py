from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import asyncio
import json

from app.core.DB.database import get_db
from app.schemas.base_schema import BaseResponse
from app.schemas.server_schema import ServerActorRequest
from fastapi.responses import StreamingResponse

from app.common.sse_docker import subscribers
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages

from app.services.server_service import (
    get_server_status_service,
    start_server_service,
    stop_server_service,
    restart_server_service,
)

server_router = APIRouter(prefix="/server", tags=["Server Management"])


@server_router.get("/status", response_model=BaseResponse)
async def get_server_status(db: Session = Depends(get_db)):
    return await get_server_status_service(db)


@server_router.post("/start", response_model=BaseResponse)
async def start_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await start_server_service(db, actor_login_id=request.user_login_id)


@server_router.post("/stop", response_model=BaseResponse)
async def stop_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await stop_server_service(
        db, actor_login_id=request.user_login_id, description=request.description
    )


@server_router.post("/restart", response_model=BaseResponse)
async def restart_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await restart_server_service(
        db, actor_login_id=request.user_login_id, description=request.description
    )


@server_router.get("/status/stream")
async def stream_status():
    queue = asyncio.Queue()
    subscribers.add(queue)

    async def event_generator():
        try:
            while True:
                try:
                    payload = await asyncio.wait_for(queue.get(), timeout=30)

                    json_str = create_response(
                        CustomCode.DOCKER_001.value,
                        Messages.SERVER_READY.value,
                        data=payload,
                    ).model_dump_json()

                    yield f"data: {json_str}\n\n"

                except asyncio.TimeoutError:
                    json_str = create_response(
                        CustomCode.HEARTBEAT_001.value,
                        Messages.HEARTBEAT_SUCCESS.value,
                        data={"heartbeat": True},
                    ).model_dump_json()

                    yield f"data: {json_str}\n\n"

        except asyncio.CancelledError:
            pass
        finally:
            subscribers.discard(queue)

    return StreamingResponse(event_generator(), media_type="text/event-stream")
