from fastapi import APIRouter, Query, status
from typing import Optional
from app.schemas.base_schema import BaseResponse
from app.services.metrics_service import get_server_metrics_service, get_timeseries_service


metrics_router = APIRouter(prefix="/api/v1/dashboard", tags=["Metircs"])


@metrics_router.get("/server/metrics", response_model=BaseResponse, status_code=status.HTTP_200_OK)
async def get_server_metrics():
    return await get_server_metrics_service()


@metrics_router.get("/server/timeseries")
async def gpu_util(end: Optional[str] = Query(None, description="RFC3339(…Z) 또는 epoch 초")):
    return await get_timeseries_service(end_iso=end)
