from pydantic import Field
from app.schemas.base_schema import BaseRequest


class UserLoginRequest(BaseRequest):
    login_id: str = Field(..., min_length=1, description="사용자 로그인 아이디")
    password: str = Field(..., min_length=1, description="사용자 비밀번호")
