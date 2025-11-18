from pydantic import BaseModel
from datetime import date


class LogRequest(BaseModel):
    start_date: date | None = None
    end_date: date | None = None
    username: str | None = None
    type: str | None = None
    description: str | None = None
    global_search: str | None = None


class ModelLogRequest(BaseModel):
    model_name: str | None = None
    cursor: str | None = None
    request_id: str | None = None
    start: str | None = None
    end: str | None = None
    level: str | None = None
    global_search: str | None = None
    limit: int | None = 200


class ServerLogRequest(BaseModel):
    cursor: str | None = None
    start: str | None = None
    end: str | None = None
    level: str | None = None
    global_search: str | None = None
    limit: int | None = 200
