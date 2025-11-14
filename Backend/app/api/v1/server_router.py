from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.base_schema import BaseResponse
from app.schemas.server_schema import ServerActorRequest
from app.services.server_service import (
    get_server_status_service,
    start_server_service,
    stop_server_service,
    restart_server_service,
)

server_router = APIRouter(prefix="/api/v1/server", tags=["Server Management"])


# 서버 상태 조회
@server_router.get("/status", response_model=BaseResponse)
async def get_server_status(db: Session = Depends(get_db)):
    return await get_server_status_service(db)


# 서버 시작
@server_router.post("/start", response_model=BaseResponse)
async def start_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await start_server_service(db, actor_login_id=request.user_login_id)


# 서버 중지
@server_router.post("/stop", response_model=BaseResponse)
async def stop_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await stop_server_service(
        db,
        actor_login_id=request.user_login_id,
        description=request.description
    )


# 서버 재시작
@server_router.post("/restart", response_model=BaseResponse)
async def restart_server(request: ServerActorRequest, db: Session = Depends(get_db)):
    return await restart_server_service(
        db,
        actor_login_id=request.user_login_id,
        description=request.description
    )