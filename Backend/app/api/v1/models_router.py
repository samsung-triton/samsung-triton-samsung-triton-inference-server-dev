from fastapi import APIRouter, UploadFile, File, Depends, status, Path, Form, Body
from typing import List, Annotated

from sqlalchemy.orm import Session
from app.core.database import get_db

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

model_router = APIRouter(prefix="/api/v1/models", tags=["models"])


@model_router.get("", response_model=BaseResponse, status_code=status.HTTP_200_OK, summary="모델 목록 (전체) 조회")
def list_models(db: Session = Depends(get_db)):
    return list_models_service(db=db)


@model_router.post("", summary="단일 모델 최초 등록")
def register_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    modelFile: UploadFile = File(...),
    setupFile: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return register_model_service(req=req, model_file=modelFile, config_file=setupFile, db=db)


@model_router.post("/register/ensemble", summary="앙상블 모델 등록")
def register_ensemble_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    setupFile: UploadFile = File(...,),
    db: Session = Depends(get_db),
):
    return register_ensemble_service(req=req, config_file=setupFile, db=db)


@model_router.post("/{model_id}/assets", summary="모델 관련 파일 추가 (버전·설정 통합)")
def register_model_version(
    model_id: int = Path(..., description="모델 ID"),
    loginId: str = Form(..., description="등록자 LoginId"),
    description: str | None = Form(None, description="버전 변경 내용 (선택)"),
    modelFile: UploadFile = File(...),
    setupFile: UploadFile = File(...,),
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
        req=req,
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
        req=req,
        db=db,
    )


@model_router.get("/{model_id}", summary="모델 상세 (버전 + Config) 조회")
def get_model_detail(
    model_id: int = Path(..., description="모델 ID"),
    db: Session = Depends(get_db),
):
    return get_model_detail_service(model_id=model_id, db=db)
