from pydantic import BaseModel, Field
from fastapi import Form
from typing import List
from enum import Enum

# ========== Request (요청) ==========


class ModelType(str, Enum):
    """모델 타입"""

    SINGLE = "SINGLE"
    ENSEMBLE = "ENSEMBLE"


class ModelRegisterRequest(BaseModel):
    """모델 등록 (파일 제외)"""

    modelName: str = Field(..., description="모델 이름")
    modelType: ModelType = Field(..., description="모델 타입")
    description: str = Field(..., description="등록 사유")
    userId: int = Field(..., description="등록자 ID")

    @classmethod
    def as_form(
        cls,
        modelName: str = Form(...),
        modelType: ModelType = Form(...),
        description: str = Form(...),
        userId: int = Form(...),
    ):
        return cls(
            modelName=modelName,
            modelType=modelType,
            description=description,
            userId=userId,
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
