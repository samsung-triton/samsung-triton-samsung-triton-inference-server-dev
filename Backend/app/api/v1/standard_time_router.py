from fastapi import APIRouter, Query

from app.core.response_utils import create_response
from app.core.standard_time_manager import current_standard_time, update_standard_time
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.schemas.base_schema import BaseResponse

standard_time_router = APIRouter(prefix="/standard-time", tags=["Standard Time"])


@standard_time_router.get("", response_model=BaseResponse)
def get_current_standard_time():
    base_time = current_standard_time()
    return create_response(
        CustomCode.STANDARD_TIME_001.value,
        Messages.STANDARD_TIME_FETCH_SUCCESS.value,
        {"base_time": base_time},
    )


@standard_time_router.post("", response_model=BaseResponse)
def set_standard_time(new_time: str = Query(..., description="새 기준 시각 (HH:MM 형식, 예: 15:00 또는 09:30)")):
    return update_standard_time(new_time)
