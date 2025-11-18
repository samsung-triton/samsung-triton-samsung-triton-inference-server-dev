from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from fastapi import status

from app.core.DB.database import get_db
from app.services.notification_service import get_inference_notification_service
from app.schemas.base_schema import BaseResponse


notification_router = APIRouter(prefix="/noti", tags=["Notification"])


@notification_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_inference_notification(db: Session = Depends(get_db)):
    return get_inference_notification_service(db)
