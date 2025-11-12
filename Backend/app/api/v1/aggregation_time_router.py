from fastapi import APIRouter, status, Query
from app.core.aggregation_time_manager import current_aggregation_time, update_aggregation_time

aggregation_time_router = APIRouter(prefix="/api/v1/models", tags=["aggregation_time"])


@aggregation_time_router.get("/aggregation-time", status_code=status.HTTP_200_OK)
def get_current_aggregation_time():
    base_time = current_aggregation_time()
    return {
        "code": "RESULT_001",
        "message": "집계 기준 시각 조회 성공",
        "data": {"base_time": base_time},
    }


@aggregation_time_router.post("/aggregation-time", status_code=status.HTTP_200_OK)
def set_aggregation_time(new_time: str = Query(..., description="새 기준 시각 (HH:MM 형식, 예: 15:00 또는 09:30)")):
    return update_aggregation_time(new_time)
