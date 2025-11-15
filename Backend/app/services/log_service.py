from sqlalchemy import and_
from sqlalchemy.orm import Session

from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.common.codes import CustomCode

from datetime import datetime


from app.models.server import Server
from app.models.model import ModelRelease
from app.models.user import User


def get_api_log_service(start_date, end_date, db: Session) -> BaseResponse:

    # 날짜를 datetime 범위로 변환
    start_dt = datetime.combine(start_date, datetime.min.time())
    end_dt = datetime.combine(end_date, datetime.max.time())

    # ------------------------
    # 1. server 로그 조회
    # ------------------------
    server_logs = (
        db.query(Server, User)
        .join(User, Server.actor_id == User.user_id)
        .filter(and_(Server.created_at >= start_dt, Server.created_at <= end_dt))
        .all()
    )

    server_result = []
    for server, user in server_logs:
        server_result.append(
            {
                "time": server.created_at,
                "user": user.name,
                "action": f"triton-{server.status.value}",
                "description": server.description,
            }
        )

    release_logs = (
        db.query(ModelRelease, User)
        .join(User, ModelRelease.actor_id == User.user_id)
        .filter(and_(ModelRelease.created_at >= start_dt, ModelRelease.created_at <= end_dt))
        .all()
    )

    release_result = []
    for release, user in release_logs:
        release_result.append(
            {
                "time": release.created_at,
                "user": user.name,
                "action": f"{release.type.value}-{release.action.value}",
                "description": release.reason,
            }
        )

    final_list = server_result + release_result
    final_list.sort(key=lambda x: x["time"])

    return create_response(code=CustomCode.LOG_001.value, message="조회 성공", data={"logs": final_list})
