from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from fastapi import status

from app.core.DB.clickhouse import get_clickhouse_db
from app.schemas.base_schema import BaseResponse
from app.services.notification_service import get_inference_notification_service

notification_router = APIRouter(prefix="/noti", tags=["Notification"])


notification_router = APIRouter(prefix="/noti", tags=["Notification"])


@notification_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_inference_notification(
    page: int = Query(1, ge=1, description="페이지 번호(1부터 시작)"),
    size: int = Query(8, ge=1, le=100, description="페이지당 개수"),
    db: Session = Depends(get_clickhouse_db),
):
    return get_inference_notification_service(db=db, page=page, size=size)
