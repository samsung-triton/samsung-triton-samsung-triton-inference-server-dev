from datetime import date
from app.schemas.base_schema import BaseRequest


class LogRequest(BaseRequest):
    start_date: date | None = None
    end_date: date | None = None
    username: str | None = None
    type: str | None = None
    description: str | None = None
    global_search: str | None = None


class ModelLogRequest(BaseRequest):
    model_name: str | None = None
    cursor: str | None = None
    request_id: str | None = None
    start: str | None = None
    end: str | None = None
    level: str | None = None
    global_search: str | None = None
    limit: int | None = 200


class ServerLogRequest(BaseRequest):
    cursor: str | None = None
    start: str | None = None
    end: str | None = None
    level: str | None = None
    global_search: str | None = None
    limit: int | None = 200
