from app.core.response_utils import create_response
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from datetime import datetime, timezone, timedelta
from pathlib import Path
import json

AGGREGATION_FILE = Path("app/state/aggregation_state.json")


def current_aggregation_time() -> str:
    """
    집계 기준 시각 조회 (파일 없으면 현재 시각 기준)
    날짜는 무시하고 HH:MM 형식만 사용
    """
    if not AGGREGATION_FILE.exists():
        now = datetime.now(timezone.utc).replace(second=0, microsecond=0)
        base_time = now.strftime("%H:%M")  # 시:분만 저장
        return base_time

    try:
        with open(AGGREGATION_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("base_time", "00:00")  # 기본값
    except Exception:
        # 파일 손상 시 기본값 반환
        return "00:00"


def get_aggregation_window(base_time_str: str = "15:00") -> tuple[datetime, datetime]:
    """
    HH:MM 형식의 기준 시각을 기준으로 현재 집계 구간 계산
    """
    now = datetime.now(timezone.utc)
    base_hour, base_minute = map(int, base_time_str.split(":"))

    today_base = now.replace(hour=base_hour, minute=base_minute, second=0, microsecond=0)

    if now >= today_base:
        # 기준 시각 이후 → 오늘 집계 중
        start_time = today_base
        end_time = now
    else:
        # 기준 시각 이전 → 어제 기준부터 오늘 기준까지
        start_time = today_base - timedelta(days=1)
        end_time = today_base

    return start_time, end_time


def update_aggregation_time(new_time: str):
    """
    집계 기준 시각 갱신 (HH:MM 형식)
    """
    # 유효성 검사
    try:
        hour, minute = map(int, new_time.split(":"))
        assert 0 <= hour < 24 and 0 <= minute < 60
    except Exception:
        return create_response(
            code=CustomCode.ERR_400,
            message="잘못된 시간 형식입니다. HH:MM 형태여야 합니다.",
            data={"example": "15:00"},
        )

    AGGREGATION_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(AGGREGATION_FILE, "w", encoding="utf-8") as f:
        json.dump({"base_time": new_time}, f, ensure_ascii=False, indent=2)

    return create_response(
        code=CustomCode.RESULT_003,
        message=Messages.AGGREGATION_TIME_UPDATE_SUCCESS,
        data={"base_time": new_time},
    )
