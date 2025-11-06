from pydantic import BaseModel, Field


class UserLoginRequest(BaseModel):
    loginId: str = Field(..., min_length=1, description="사용자 로그인 아이디")
    password: str = Field(..., min_length=1, description="사용자 비밀번호")
