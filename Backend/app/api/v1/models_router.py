from fastapi import APIRouter, UploadFile, File, Depends, Path, Form, Body
from typing import Annotated
from sqlalchemy.orm import Session

from app.core.DB.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.model_service import (
    list_models_service,
    register_model_service,
    register_ensemble_service,
    register_model_assets_service,
    delete_model_version_service,
    delete_model_service,
    get_model_detail_service,
)
from app.schemas.model_schema import ModelRegisterRequest, ModelDeleteRequest

model_router = APIRouter(prefix="/models", tags=["models"])


@model_router.get("", response_model=BaseResponse)
def list_models(db: Session = Depends(get_db)):
    return list_models_service(db=db)


@model_router.get("/{model_id}", response_model=BaseResponse)
def get_model_detail(
    model_id: int = Path(..., description="모델 ID"),
    db: Session = Depends(get_db),
):
    return get_model_detail_service(model_id=model_id, db=db)


@model_router.post("/normal", response_model=BaseResponse)
def register_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    modelFile: UploadFile = File(...),
    setupFile: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return register_model_service(
        model_name=req.model_name,
        model_type=req.model_type,
        description=req.description,
        login_id=req.login_id,
        model_file=modelFile,
        config_file=setupFile,
        db=db,
    )


@model_router.post("/ensemble", response_model=BaseResponse)
def register_ensemble_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    setupFile: UploadFile = File(
        ...,
    ),
    db: Session = Depends(get_db),
):
    return register_ensemble_service(
        model_name=req.model_name,
        model_type=req.model_type,
        description=req.description,
        login_id=req.login_id,
        config_file=setupFile,
        db=db,
    )


@model_router.post("/{model_id}/versions", response_model=BaseResponse)
def register_model_version(
    model_id: int = Path(..., description="모델 ID"),
    loginId: str = Form(..., description="등록자 LoginId"),
    description: str | None = Form(None, description="버전 변경 내용 (선택)"),
    modelFile: UploadFile | None = File(None, description="모델 파일 (선택)"),
    setupFile: UploadFile | None = File(None, description="환경파일 (선택)"),
    db: Session = Depends(get_db),
):
    return register_model_assets_service(
        model_id=model_id,
        login_id=loginId,
        description=description,
        model_file=modelFile,
        config_file=setupFile,
        db=db,
    )


@model_router.delete("/{model_id}/versions/{version}", response_model=BaseResponse)
def delete_model_version(
    model_id: int = Path(..., description="모델 ID"),
    version: int = Path(..., description="삭제할 버전 번호"),
    req: ModelDeleteRequest = Body(...),
    db: Session = Depends(get_db),
):
    return delete_model_version_service(
        model_id=model_id,
        version=version,
        login_id=req.login_id,
        description=req.description,
        db=db,
    )


@model_router.delete("/{model_id}", response_model=BaseResponse)
def delete_model(
    model_id: int = Path(..., description="모델 ID"),
    req: ModelDeleteRequest = Body(...),
    db: Session = Depends(get_db),
):
    return delete_model_service(
        model_id=model_id,
        login_id=req.login_id,
        description=req.description,
        db=db,
    )
