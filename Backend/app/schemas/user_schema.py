from pydantic import BaseModel, Field


class UserLoginRequest(BaseModel):
    loginId: str = Field(..., description="사용자 로그인 아이디")
    password: str = Field(..., description="사용자 비밀번호")
