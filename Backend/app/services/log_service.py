from fastapi import status
from datetime import datetime
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.models.server import Server
from app.models.model import ModelRelease
from app.models.user import User
from app.core.customException import CustomHTTPException


def get_web_log_service(
    start_date, end_date, username, type, description, global_search, page: int, size: int, db: Session
) -> BaseResponse:
    start_dt = datetime.combine(start_date, datetime.min.time())
    end_dt = datetime.combine(end_date, datetime.max.time())

    if end_date < start_date:
        raise CustomHTTPException(
            status.HTTP_400_BAD_REQUEST,
            CustomCode.ERR_400.value,
            Messages.ERR_END_DATE_BEFORE_START_DATE.value,
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

    if global_search:
        final_list = [
            log
            for log in final_list
            if (log.get("username") and global_search in log["username"])
            or (log.get("description") and global_search in log["description"])
        ]

    else:
        if username:
            final_list = [log for log in final_list if log.get("username") and username in log["username"]]

        if description:
            final_list = [log for log in final_list if log.get("description") and description in log["description"]]

    if type:
        final_list = [log for log in final_list if type in log["type"]]

    final_list.sort(key=lambda x: x["date"], reverse=True)

    total = len(final_list)
    offset = (page - 1) * size
    paginated_items = final_list[offset : offset + size]

    total_pages = (total + size - 1) // size if total else 0

    return create_response(
        code=CustomCode.LOG_001.value,
        message=Messages.WEB_LOG_FETCH_SUCCESS.value,
        data={
            "items": paginated_items,
            "page": page,
            "size": size,
            "total": total,
            "totalPages": total_pages,
        },
    )


def get_model_name_list_service(db):
    sql = text(
        """
        SELECT DISTINCT model_name
        FROM logs.triton_infer_logs
        WHERE model_name NOT IN ('', 'unknown')
        ORDER BY model_name ASC
    """
    )

    rows = db.execute(sql).fetchall()
    model_names = [r[0] for r in rows]

    return create_response(
        CustomCode.LOG_002,
        Messages.INFER_LOG_MODEL_NAME_LIST_FETCH_SUCCESS,
        {"models": model_names},
    )


def _add_cond(where: list, cond: str | None):
    if cond:
        where.append(cond)


def get_infer_logs_service(db, model_name, start, end, level, cursor, request_id, global_search, limit):
    # 날짜 유효성 체크
    if (start and not end) or (end and not start):
        return create_response(
            CustomCode.ERR_400,
            Messages.ERR_END_DATE_TOGETHER_START_DATE,
            None,
        )

    if start and end and end < start:
        return create_response(
            CustomCode.ERR_400,
            Messages.ERR_END_DATE_BEFORE_START_DATE,
            None,
        )

    # WHERE 조건 생성
    where = []

    _add_cond(where, f"model_name = '{model_name}'" if model_name else None)

    if start and end:
        _add_cond(where, f"ts >= '{start} 00:00:00'")
        _add_cond(where, f"ts <= '{end} 23:59:59'")

    _add_cond(where, f"level = '{level}'" if level else None)
    _add_cond(where, f"request_id = '{request_id}'" if request_id else None)

    if global_search:
        _add_cond(where, f"message LIKE '%{global_search}%'")

    # cursor = ts
    # ts DESC 기준으로 과거 로그 조회
    if cursor:
        _add_cond(where, f"ts < '{cursor}'")

    where_sql = " AND ".join(where) if where else "1=1"

    # SQL 실행
    sql = text(
        f"""
        SELECT
            toString(ts) AS ts_raw,
            formatDateTime(ts, '%Y-%m-%dT%TZ') AS iso_utc,
            level,
            message,
            request_id,
            model_name,
            uid
        FROM triton_infer_logs
        WHERE {where_sql}
        ORDER BY ts DESC
        LIMIT {limit}
    """
    )
    rows = db.execute(sql).fetchall()

    # cursor 반환 포함 return
    logs = []

    for r in rows:
        logs.append(
            {
                "ts": r[1],  # iso_utc
                "level": r[2],
                "message": r[3],
                "requestId": r[4],
                "modelMame": r[5],
                "uid": r[6],
            }
        )

    # cursor 만들기
    next_cursor = rows[-1][0] if rows else None

    return create_response(
        CustomCode.LOG_003,
        Messages.INFER_LOG_FETCH_SUCCESS,
        {
            "logs": logs,
            "nextCursor": next_cursor,
        },
    )


def get_server_logs_service(db, start, end, level, cursor, global_search, limit):
    # 날짜 유효성 체크
    if (start and not end) or (end and not start):
        return create_response(
            CustomCode.ERR_400,
            Messages.ERR_END_DATE_TOGETHER_START_DATE,
            None,
        )

    if start and end and end < start:
        return create_response(
            CustomCode.ERR_400,
            Messages.ERR_END_DATE_BEFORE_START_DATE,
            None,
        )

    # WHERE 조건 구성
    where = []
    if start and end:
        _add_cond(where, f"ts >= '{start} 00:00:00'")
        _add_cond(where, f"ts <= '{end} 23:59:59'")

    _add_cond(where, f"level = '{level}'" if level else None)

    if global_search:
        _add_cond(where, f"message LIKE '%{global_search}%'")

    # cursor = ts
    if cursor:
        _add_cond(where, f"ts < '{cursor}'")

    where_sql = " AND ".join(where) if where else "1=1"

    # SQL 실행
    sql = text(
        f"""
        SELECT
            toString(ts) AS ts_raw,
            formatDateTime(ts, '%Y-%m-%dT%TZ') AS iso_utc,
            level,
            message
        FROM triton_logs
        WHERE {where_sql}
        ORDER BY ts DESC
        LIMIT {limit}
    """
    )

    rows = db.execute(sql).fetchall()

    # 결과 변환
    logs = [
        {
            "ts": r[1],
            "level": r[2],
            "message": r[3],
        }
        for r in rows
    ]

    next_cursor = rows[-1][0] if rows else None

    return create_response(
        CustomCode.LOG_004,
        Messages.SERVER_LOG_FETCH_SUCCESS,
        {
            "logs": logs,
            "nextCursor": next_cursor,
        },
    )
