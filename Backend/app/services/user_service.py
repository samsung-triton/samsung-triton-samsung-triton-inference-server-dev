from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.base_schema import BaseResponse
from fastapi import HTTPException, status


def login_user_service(login_id: str, password: str, db: Session) -> BaseResponse:
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
