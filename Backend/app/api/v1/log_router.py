from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from fastapi import status
from datetime import datetime

from app.core.database import get_db
from app.services.log_service import get_api_log_service
from app.schemas.base_schema import BaseResponse

log_router = APIRouter(prefix="/api/v1/logs", tags=["Log"])


@log_router.get("/api", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_api_log(
    start_date: datetime = Query(..., description="조회 시작일"),
    end_date: datetime = Query(..., description="조회 종료일"),
    db: Session = Depends(get_db),
):
    return get_api_log_service(start_date, end_date, db)
