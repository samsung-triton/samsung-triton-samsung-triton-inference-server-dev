from fastapi import HTTPException
from app.schemas.base_schema import BaseResponse


def create_response(code: str, message: str, data: dict | None = None) -> BaseResponse:
    return BaseResponse(code=code, message=message, data=data)


def raise_http_exception(status_code: int, code: str, message: str, data: dict | None = None):
    raise HTTPException(status_code=status_code, detail=create_response(code, message, data).dict())
