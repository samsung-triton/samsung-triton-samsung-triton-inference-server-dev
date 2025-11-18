from fastapi import APIRouter, Query, status, Depends, Path
from sqlalchemy.orm import Session
from typing import Optional

from app.core.DB.database import get_db
from app.schemas.base_schema import BaseResponse
from app.services.metrics_service import (
    get_server_metrics_service,
    get_timeseries_service,
    get_model_per_inference_stats_service,
    get_model_per_inference_latency_service,
)

metrics_router = APIRouter(prefix="/dashboard", tags=["Metircs"])


@metrics_router.get("/server/metrics", response_model=BaseResponse, status_code=status.HTTP_200_OK)
async def get_server_metrics():
    return await get_server_metrics_service()


@metrics_router.get("/model/{model_id}/stats", response_model=BaseResponse, status_code=status.HTTP_200_OK)
def get_model_per_inference_stats(model_id: int = Path(...), db: Session = Depends(get_db)):
    return get_model_per_inference_stats_service(model_id, db)


@metrics_router.get("/model/{model_id}/latency", response_model=BaseResponse, status_code=status.HTTP_200_OK)
async def get_model_per_inference_latency(
    model_id: int = Path(...), end: Optional[str] = Query(None), db: Session = Depends(get_db)
):
    return await get_model_per_inference_latency_service(model_id, end, db)


@metrics_router.get("/server/timeseries")
async def gpu_util(end: Optional[str] = Query(None, description="RFC3339(…Z) 또는 epoch 초")):
    return await get_timeseries_service(end_iso=end)
