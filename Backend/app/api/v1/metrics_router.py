from fastapi import APIRouter, Query, status, Depends
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.metrics_service import get_server_metrics_service, get_timeseries_service
from app.services.inferdata_service import get_model_per_inference_stats_service

metrics_router = APIRouter(prefix="/api/v1/dashboard", tags=["Metircs"])


@metrics_router.get("/server/metrics", response_model=BaseResponse, status_code=status.HTTP_200_OK)
async def get_server_metrics():
    return await get_server_metrics_service()


@metrics_router.get("/server/timeseries")
async def gpu_util(end: Optional[str] = Query(None, description="RFC3339(…Z) 또는 epoch 초")):
    return await get_timeseries_service(end_iso=end)


@metrics_router.get("/model/stats", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_model_per_inference_stats(
    model_name: str = Query(..., description="조회할 모델 이름 (예: densenet_onnx)"), db: Session = Depends(get_db)
):
    return get_model_per_inference_stats_service(model_name, db)
