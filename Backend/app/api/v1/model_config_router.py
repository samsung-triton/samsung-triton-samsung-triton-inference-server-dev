from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.schemas.model_config_schema import ConfigUpdateRequest
from app.core.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.model_config_service import (
    delete_selected_config_service,
    get_config_history_with_selected_service,
    get_current_config_service,
    get_rollback_config_list_service,
    get_selected_config_service,
    update_model_config_service,
)

model_config_router = APIRouter(prefix="/api/v1/models", tags=["Model Config"])


# 현재 사용 중인 Config 조회
@model_config_router.get("/{model_id}/config/current", response_model=BaseResponse)
async def get_current_config(model_id: int, db: Session = Depends(get_db)):
    return await get_current_config_service(db, model_id)


# Config 롤백 목록 조회
@model_config_router.get("/{model_id}/config/history", response_model=BaseResponse)
async def get_rollback_config_list(model_id: int, db: Session = Depends(get_db)):
    return await get_rollback_config_list_service(db, model_id)


# 특정 Config 상세 내용 조회
@model_config_router.get("/{model_id}/config/{config_id}", response_model=BaseResponse)
async def get_selected_config(model_id: int, config_id: int, db: Session = Depends(get_db)):
    return await get_selected_config_service(db, model_id, config_id)


# 특정 Config 삭제
@model_config_router.delete("/{model_id}/config/{config_id}", response_model=BaseResponse)
async def delete_selected_config(model_id: int, config_id: int, db: Session = Depends(get_db)):
    return await delete_selected_config_service(db, model_id, config_id)


# Config 이력 + 선택된 Config 상세 내용 함께 조회
@model_config_router.get("/{model_id}/config", response_model=BaseResponse)
async def get_config_history_with_selected(
    model_id: int,
    config_id: int | None = None,
    db: Session = Depends(get_db),
):
    """
    Config 이력 + 선택된 Config 상세 내용을 함께 반환
    (config_id가 없으면 현재 is_current=True인 Config 반환)
    """
    return await get_config_history_with_selected_service(db, model_id, config_id)


# 모델 Config 파일 교체 및 Triton 반영
@model_config_router.patch("/{model_id}/config/apply", response_model=BaseResponse)
async def update_model_config(model_id: int, request: ConfigUpdateRequest, db: Session = Depends(get_db)):
    return update_model_config_service(
        model_id=model_id,
        login_id=request.loginId,
        config_content=request.configContent,
        description=request.description,
        db=db,
    )
