from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.schemas.user_schema import UserLoginRequest
from app.core.DB.database import get_db
from app.services.user_service import login_user_service
from app.schemas.base_schema import BaseResponse

user_router = APIRouter(prefix="/auth", tags=["User"])


@user_router.post("/login", response_model=BaseResponse)
def login_user(request: UserLoginRequest, db: Session = Depends(get_db)):
    """유저 로그인"""
    return login_user_service(request.login_id, request.password, db)
