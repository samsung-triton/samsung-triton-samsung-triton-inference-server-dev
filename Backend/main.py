from fastapi import FastAPI
from app.core.database import SessionLocal
from sqlalchemy import text
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

    return app


app = create_app()
