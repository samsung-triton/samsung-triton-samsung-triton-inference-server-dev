from fastapi import status
from sqlalchemy import and_
from sqlalchemy.orm import Session
from datetime import datetime

from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.models.server import Server
from app.models.model import ModelRelease
from app.models.user import User
from app.core.customException import CustomHTTPException


def get_api_log_service(start_date, end_date, db: Session) -> BaseResponse:

    start_dt = datetime.combine(start_date, datetime.min.time())
    end_dt = datetime.combine(end_date, datetime.max.time())

    if end_date < start_date:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            detail=Messages.ERR_END_DATE_BEFORE_START_DATE.value,
        )

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

    return create_response(
        code=CustomCode.LOG_001.value, message=Messages.MODEL_API_LOG_FETCH_SUCCESS.value, data={"logs": final_list}
    )
