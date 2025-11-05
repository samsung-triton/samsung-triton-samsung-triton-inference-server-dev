from fastapi.responses import JSONResponse


def raise_http_exception(status_code: int, code: str, message: str, data: dict | None = None):
    return JSONResponse(status_code=status_code, content={"code": code, "message": message, "data": data})
