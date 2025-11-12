from typing import List
from fastapi import APIRouter, Depends, UploadFile, File, Form, status, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.inferdata_service import (
    save_input_before_infer_service,
    save_output_after_infer_service,
    get_model_per_inference_stats_service,
)  # noqa: E501
from app.schemas.base_schema import BaseResponse
from app.schemas.inferoutput_schema import SaveInferenceResultRequest


inferdata_router = APIRouter(prefix="/api/v1/infer", tags=["InferData"])


@inferdata_router.post("/save/before", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def save_input_before_infer(
    clientId: str = Form(..., description="추론 전 입력 데이터 저장"),
    modelName: str = Form(..., description="추론할 모델 id"),
    dataFiles: List[UploadFile] = File(..., description="추론 입력 데이터 리스트 (.npy, .ply 등)"),
    db: Session = Depends(get_db),
):
    return save_input_before_infer_service(clientId, modelName, dataFiles, db)


@inferdata_router.post("/save/after", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def save_output_after_infer(request: SaveInferenceResultRequest, db: Session = Depends(get_db)):
    return save_output_after_infer_service(request.uid, request.is_ok, request.result, db)


@inferdata_router.get("/stats", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_model_per_inference_stats(
    model_name: str = Query(..., description="조회할 모델 이름 (예: densenet_onnx)"), db: Session = Depends(get_db)
):
    return get_model_per_inference_stats_service(model_name, db)
