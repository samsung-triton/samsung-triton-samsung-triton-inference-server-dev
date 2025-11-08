from fastapi import APIRouter, HTTPException, UploadFile, File, Depends, status
from typing import List, Annotated

from sqlalchemy.orm import Session
from app.core.database import get_db

from app.schemas.base_schema import BaseResponse
from app.services.model_service import list_models_service, register_model_service
from app.schemas.model_schema import ModelRegisterRequest

model_router = APIRouter(prefix="/api/v1/models", tags=["models"])


@model_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK, summary="모델 목록 (전체) 조회")
def list_models():
    return list_models_service()


@model_router.post("", summary="모델 최초 등록")
def register_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    modelFiles: List[UploadFile] = File(..., description="모델 파일들 (.onnx / .plan / .pt / .pth 등)"),
    configFile: UploadFile = File(..., description="Triton 설정 파일 (config.pbtxt)"),
    db: Session = Depends(get_db),
):
    """
    - TRITON_MODEL_REPO 아래에 모델 디렉토리 생성
    - config.pbtxt는 <modelName>/config.pbtxt
    - 모델 파일은 <modelName>/1/ 아래에 저장
    - DB에 model / model_version / model_file 기록
    """
    return register_model_service(
        req=req,
        model_files=modelFiles,
        config_file=configFile,
        db=db,
    )
