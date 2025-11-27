from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.schemas.model_config_schema import ConfigUpdateRequest, ConfigDeleteRequest
from app.core.DB.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.model_config_service import (
    delete_selected_config_service,
    get_config_history_with_selected_service,
    update_model_config_service,
)

model_config_router = APIRouter(prefix="/models", tags=["Model Config"])


# Config 이력 + Config 상세 내용 함께 조회
@model_config_router.get("/{model_id}/config", response_model=BaseResponse)
async def get_config_history_with_selected(
    model_id: int,
    db: Session = Depends(get_db),
):
    return await get_config_history_with_selected_service(db, model_id)


# 모델 Config 파일 교체 및 Triton 반영
@model_config_router.post("/{model_id}/config", response_model=BaseResponse)
async def update_model_config(model_id: int, request: ConfigUpdateRequest, db: Session = Depends(get_db)):
    return update_model_config_service(
        model_id=model_id,
        login_id=request.login_id,
        config_content=request.config_content,
        description=request.description,
        db=db,
    )


# 특정 Config 삭제
@model_config_router.delete("/{model_id}/config/{config_id}", response_model=BaseResponse)
async def delete_selected_config(
    model_id: int, config_id: int, request: ConfigDeleteRequest, db: Session = Depends(get_db)
):
    return await delete_selected_config_service(
        db, model_id, config_id, login_id=request.login_id, description=request.description
    )
