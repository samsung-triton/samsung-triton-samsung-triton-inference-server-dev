import json
from fastapi import status
from datetime import datetime
from pathlib import Path

from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.customException import CustomHTTPException
from app.core.config import TIMEZONE


STANDARD_TIME_FILE = Path("app/state/standard_state.json")


def current_standard_time() -> str:
    """
    집계 기준 시각 조회 (파일 없으면 현재 시각 기준)
    날짜는 무시하고 HH:MM 형식만 사용
    """

    if not STANDARD_TIME_FILE.exists():
        now = datetime.now(TIMEZONE).replace(second=0, microsecond=0)
        base_time = now.strftime("%H:%M")  # 시:분만 저장
        return base_time

    try:
        with open(STANDARD_TIME_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("base_time", "00:00")  # 기본값
    except Exception:
        # 파일 손상 시 기본값 반환
        return "00:00"


def update_standard_time(new_time: str):
    """
    집계 기준 시각 갱신 (HH:MM 형식)
    """
    # 유효성 검사
    try:
        hour, minute = map(int, new_time.split(":"))
        assert 0 <= hour < 24 and 0 <= minute < 60
    except Exception:
        raise CustomHTTPException(  # 이것도.. main에서 잡을 것 같은데
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.INVALID_STANDARD_TIME_FORMAT.value,
            data=None,
        )

    STANDARD_TIME_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STANDARD_TIME_FILE, "w", encoding="utf-8") as f:
        json.dump({"base_time": new_time}, f, ensure_ascii=False, indent=2)

    return create_response(
        code=CustomCode.STANDARD_TIME_002.value,
        message=Messages.STANDARD_TIME_UPDATE_SUCCESS.value,
        data={"baseTime": new_time},
    )
