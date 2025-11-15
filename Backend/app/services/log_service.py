from fastapi import status
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


def get_api_log_service(start_date, end_date, username, type, description, db: Session) -> BaseResponse:

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
        .filter(Server.created_at >= start_dt, Server.created_at <= end_dt)
        .all()
    )

    server_result = []
    for server, user in server_logs:
        log_type = f"TRITON-{server.status.value}"
        server_result.append(
            {
                "date": server.created_at,
                "username": user.name,
                "type": log_type,
                "description": server.description,
            }
        )

    release_logs = (
        db.query(ModelRelease, User)
        .join(User, ModelRelease.actor_id == User.user_id)
        .filter(ModelRelease.created_at >= start_dt, ModelRelease.created_at <= end_dt)
        .all()
    )

    release_result = []
    for release, user in release_logs:
        log_type = f"{release.type.value}-{release.action.value}"
        release_result.append(
            {
                "date": release.created_at,
                "username": user.name,
                "type": log_type,
                "description": release.reason,
            }
        )

    final_list = server_result + release_result

    if username:
        final_list = [log for log in final_list if log["username"] == username]
    if description:
        final_list = [log for log in final_list if log.get("description") and description in log["description"]]
    if type:
        final_list = [log for log in final_list if type in log["type"]]

    final_list.sort(key=lambda x: x["date"])

    return create_response(
        code=CustomCode.LOG_001.value, message=Messages.MODEL_API_LOG_FETCH_SUCCESS.value, data={"logs": final_list}
    )
