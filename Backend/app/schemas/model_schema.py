from pydantic import BaseModel, Field
from fastapi import Form
from typing import List, Optional
from app.models.model import ModelType

# ========== Request (요청) ==========


class ModelRegisterRequest(BaseModel):
    """모델 등록 (파일 제외)"""

    modelName: str = Field(..., description="모델 이름")
    modelType: ModelType = Field(..., description="모델 타입")
    description: str = Field(None, description="등록 사유")
    LoginId: str = Field(..., description="등록자 ID")

    @classmethod
    def as_form(
        cls,
        modelName: str = Form(...),
        modelType: ModelType = Form(...),
        description: Optional[str] = Form(None),
        LoginId: str = Form(...),
    ):
        return cls(
            modelName=modelName,
            modelType=modelType,
            description=description,
            LoginId=LoginId,
        )


class ModelDeleteRequest(BaseModel):
    loginId: str = Field(..., description="요청자 로그인 ID")
    description: Optional[str] = Field(None, description="삭제 이유")
