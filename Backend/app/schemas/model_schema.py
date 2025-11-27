from pydantic import Field
from fastapi import Form
from typing import Optional
from app.models.model import ModelType
from app.schemas.base_schema import BaseRequest


class ModelRegisterRequest(BaseRequest):
    """모델 등록 (파일 제외)"""

    model_name: str = Field(..., description="모델 이름")
    model_type: ModelType = Field(..., description="모델 타입")
    description: str = Field(None, description="등록 사유")
    login_id: str = Field(..., description="등록자 ID")

    @classmethod
    def as_form(
        cls,
        modelName: str = Form(...),
        modelType: ModelType = Form(...),
        description: Optional[str] = Form(None),
        loginId: str = Form(...),
    ):
        return cls(
            model_name=modelName,
            model_type=modelType,
            description=description,
            login_id=loginId,
        )


class ModelDeleteRequest(BaseRequest):
    login_id: str = Field(..., description="요청자 로그인 ID")
    description: Optional[str] = Field(None, description="삭제 이유")
