from pydantic import BaseModel
from datetime import date


class LogRequest(BaseModel):
    start_date: date
    end_date: date
    username: str | None
    type: str | None
    description: str | None
