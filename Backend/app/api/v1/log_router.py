from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from fastapi import status

from app.core.database import get_db
from app.services.log_service import get_api_log_service
from app.schemas.base_schema import BaseResponse
from app.schemas.log_schema import LogRequest


log_router = APIRouter(prefix="/api/v1/logs", tags=["Log"])


@log_router.post("/api", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_api_log(request: LogRequest, db: Session = Depends(get_db)):
    return get_api_log_service(
        start_date=request.start_date,
        end_date=request.end_date,
        username=request.username,
        type=request.type,
        description=request.description,
        db=db,
    )
