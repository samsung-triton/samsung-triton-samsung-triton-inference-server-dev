from fastapi.exceptions import RequestValidationError
from fastapi import FastAPI, Request, status, HTTPException
from sqlalchemy import text
from fastapi.responses import JSONResponse
from app.core.database import SessionLocal
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.core.customException import CustomHTTPException

import logging
from app.api.v1.router import api_router

logger = logging.getLogger("uvicorn")


def create_app() -> FastAPI:
    app = FastAPI(title="Triton Gateway")

    app.include_router(api_router)

    @app.on_event("startup")
    async def startup_event():
        try:
            db = SessionLocal()
            db.execute(text("SELECT 1"))
            logger.info("DB 연결 성공")
        except Exception as e:
            logger.error(f"DB 연결 실패: {e}")
        finally:
            db.close()

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"code": CustomCode.ERR_400.value, "message": Messages.INVALID_PARAM.value, "data": None},
        )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        if isinstance(exc, CustomHTTPException):
            content = {
                "code": exc.code,
                "message": exc.message,
                "data": exc.data,
            }
        else:
            content = {
                "code": f"ERR-{exc.status_code}",
                "message": str(exc.detail) if exc.detail else "서버 내부 오류가 발생했습니다.",
                "data": None,
            }

        return JSONResponse(status_code=exc.status_code, content=content)

    return app


app = create_app()
