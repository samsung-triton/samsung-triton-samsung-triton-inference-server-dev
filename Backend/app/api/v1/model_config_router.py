from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.model_config_service import get_current_config_service

config_router = APIRouter(prefix="/api/v1/configs", tags=["Model Config"])

@config_router.get("/models/{model_id}/config/current", response_model=BaseResponse)
async def get_current_config(model_id: int, db: Session = Depends(get_db)):
    return await get_current_config_service(db, model_id)
