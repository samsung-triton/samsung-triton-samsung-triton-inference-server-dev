from pydantic import BaseModel, Field
from fastapi import Form
from typing import List, Optional
from enum import Enum

# ========== Request (요청) ==========


class ModelType(str, Enum):
    """모델 타입"""

    NORMAL = "NORMAL"
    ENSEMBLE = "ENSEMBLE"


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


# ========== Response (응답) ==========


class FileInfoDTO(BaseModel):
    """파일 정보 DTO"""

    fileName: str
    filePath: str


class ModelRegisterResponse(BaseModel):
    """모델 등록 응답 DTO"""

    modelId: int
    modelName: str
    modelType: str
    files: List[FileInfoDTO]
    description: str
    status: str
    createdBy: str
    createdAt: str
