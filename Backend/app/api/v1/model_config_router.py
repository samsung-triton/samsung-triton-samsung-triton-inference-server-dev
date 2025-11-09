from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.model_config_service import get_current_config_service, get_rollback_config_list_service

model_config_router = APIRouter(prefix="/api/v1/configs", tags=["Model Config"])

# 현재 사용 중인 Config 조회
@model_config_router.get("/models/{model_id}/config/current", response_model=BaseResponse)
async def get_current_config(model_id: int, db: Session = Depends(get_db)):
    return await get_current_config_service(db, model_id)

# Config 롤백 목록 조회
@model_config_router.get("/models/{model_id}/config/history", response_model=BaseResponse)
async def get_rollback_config_list(model_id: int, db: Session = Depends(get_db)):
    return await get_rollback_config_list_service(db, model_id)