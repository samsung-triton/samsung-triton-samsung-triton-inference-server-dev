from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session
from app.schemas.user_schema import UserLoginRequest
from app.schemas.base_schema import BaseResponse
from app.core.database import get_db
from app.models.user import User

user_router = APIRouter(prefix="/api/v1/auth", tags=["User"])


@user_router.post("/login", response_model=BaseResponse)
def login_user(request: UserLoginRequest, db: Session = Depends(get_db)):
    login_id = request.loginId
    password = request.password

    if not login_id or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "ERR-400", "message": "요청 파라미터가 올바르지 않습니다.", "data": None},
        )

    user = db.query(User).filter(User.login_id == login_id).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "ERR-404", "message": "해당 유저를 찾을 수 없습니다.", "data": None},
        )

    if user.password != password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "ERR-401", "message": "아이디 또는 비밀번호가 일치하지 않습니다.", "data": None},
        )

    return BaseResponse(
        code="AUTH-002",
        message=f"{user.name}님, 로그인이 성공적으로 완료되었습니다.",
        data={"user_id": user.user_id, "role": user.role},
    )
