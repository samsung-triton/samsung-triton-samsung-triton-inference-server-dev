from fastapi import APIRouter, UploadFile, File, Depends, status, Path, Form, Body
from typing import List, Annotated

from sqlalchemy.orm import Session
from app.core.database import get_db

from app.schemas.base_schema import BaseResponse
from app.services.model_service import (
    list_models_service,
    register_model_service,
    register_ensemble_service,
    register_model_version_service,
    delete_model_version_service,
    delete_model_service,
)
from app.schemas.model_schema import ModelRegisterRequest, ModelDeleteRequest

model_router = APIRouter(prefix="/api/v1/models", tags=["models"])


@model_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK, summary="모델 목록 (전체) 조회")
def list_models():
    return list_models_service()


@model_router.post("", summary="단일 모델 최초 등록")
def register_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    modelFiles: List[UploadFile] = File(...),
    configFile: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return register_model_service(req=req, model_files=modelFiles, config_file=configFile, db=db)


@model_router.post("/register/ensemble", summary="앙상블 모델 등록")
def register_ensemble_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    configFile: UploadFile = File(..., description="config.pbtxt 파일"),
    db: Session = Depends(get_db),
):
    return register_ensemble_service(req=req, config_file=configFile, db=db)


@model_router.post("/{model_id}/versions", summary="모델 버전 추가")
def register_model_version(
    model_id: int = Path(..., description="모델 ID"),
    loginId: str = Form(..., description="등록자 LoginId"),
    description: str | None = Form(None, description="버전 변경 내용 (선택)"),
    modelFiles: List[UploadFile] = File(...),
    db: Session = Depends(get_db),
):
    """
    - 기존 모델에 버전 추가
    - version은 자동 증가
    """
    return register_model_version_service(
        model_id=model_id,
        login_id=loginId,
        description=description,
        model_files=modelFiles,
        db=db,
    )


@model_router.delete("/{model_id}/versions/{version}", summary="모델 버전 삭제")
def delete_model_version(
    model_id: int = Path(..., description="모델 ID"),
    version: int = Path(..., description="삭제할 버전 번호"),
    req: ModelDeleteRequest = Body(...),
    db: Session = Depends(get_db),
):
    return delete_model_version_service(
        model_id=model_id,
        version=version,
        login_id=req.loginId,
        db=db,
    )


@model_router.delete("/{model_id}", summary="모델 전체 삭제")
def delete_model(
    model_id: int = Path(..., description="모델 ID"),
    req: ModelDeleteRequest = Body(...),
    db: Session = Depends(get_db),
):
    return delete_model_service(
        model_id=model_id,
        login_id=req.loginId,
        db=db,
    )
