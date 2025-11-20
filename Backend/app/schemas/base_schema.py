from pydantic import BaseModel


class BaseResponse(BaseModel):
    code: str
    message: str
    data: dict | None = None
