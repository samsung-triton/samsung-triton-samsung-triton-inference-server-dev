from fastapi import FastAPI, status, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text
from clickhouse_sqlalchemy import make_session

from app.core.DB.database import SessionLocal
from app.core.DB.clickhouse import ch_engine
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.customException import CustomHTTPException
from app.core.config import settings

import asyncio
import logging

from app.api.v1.router import api_router
from app.common.docker_sse import docker_event_watcher

logger = logging.getLogger("uvicorn")


def create_app():
    app = FastAPI(title="Triton Gateway")

    # =====================
    # CORS 설정
    # =====================
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # =====================
    # 라우터 등록
    # =====================
    app.include_router(api_router)

    # =====================
    # Startup Event
    # =====================
    @app.on_event("startup")
    async def startup_event():
        # PostgreSQL 연결 테스트
        try:
            db = SessionLocal()
            db.execute(text("SELECT 1"))
            logger.info("PostgreSQL DB 연결 성공")
        except Exception as e:
            logger.error(f"PostgreSQL DB 연결 실패: {e}")
        finally:
            db.close()

        # ClickHouse 연결 테스트
        try:
            ch = make_session(ch_engine)
            ch.execute(text("SELECT 1"))
            logger.info("ClickHouse DB 연결 성공")
        except Exception as e:
            logger.error(f"ClickHouse DB 연결 실패: {e}")
        finally:
            ch.close()

        # Docker 이벤트 스트림 실행
        asyncio.create_task(docker_event_watcher(settings.TRITON_CONTAINER_NAME))
        logger.info("Docker 이벤트 감시 시작")

    # =====================
    # 예외 핸들러
    # =====================
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
                "message": str(exc.detail) or "서버 내부 오류가 발생했습니다.",
                "data": None,
            }

        return JSONResponse(status_code=exc.status_code, content=content)

    return app


app = create_app()
