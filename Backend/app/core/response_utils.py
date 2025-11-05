from app.schemas.base_schema import BaseResponse


def create_response(code: str, message: str, data: dict | None = None) -> BaseResponse:
    return BaseResponse(code=code, message=message, data=data)
