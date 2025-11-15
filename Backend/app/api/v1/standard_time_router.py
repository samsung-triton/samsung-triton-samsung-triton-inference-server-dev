from fastapi import APIRouter, status, Query

from app.core.response_utils import create_response
from app.core.standard_time_manager import current_standard_time, update_standard_time
from app.common.codes import CustomCode
from app.common.messages import Messages

standard_time_router = APIRouter(prefix="/api/v1/models", tags=["Standard Time"])


@standard_time_router.get("/standard-time", status_code=status.HTTP_200_OK)
def get_current_standard_time():
    base_time = current_standard_time()
    return create_response(
        CustomCode.STANDARD_TIME_001.value,
        Messages.STANDARD_TIME_FETCH_SUCCESS.value,
        {"base_time": base_time},
    )


@standard_time_router.post("/standard-time", status_code=status.HTTP_200_OK)
def set_standard_time(new_time: str = Query(..., description="새 기준 시각 (HH:MM 형식, 예: 15:00 또는 09:30)")):
    return update_standard_time(new_time)
