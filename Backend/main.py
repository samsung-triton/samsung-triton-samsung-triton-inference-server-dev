# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.routers import api_router

tags_metadata = [
    {"name": "server", "description": "Triton 서버 상태/메타"},
    {"name": "models", "description": "모델 상태 확인"},
]

def create_app() -> FastAPI:
    app = FastAPI(
        title="Triton Admin (minimal)",
        description="프론트가 호출하는 최소 API (health / metadata / model ready)",
        version="0.1.0",
        openapi_tags=tags_metadata,
        docs_url="/docs",
        redoc_url="/redoc",
    )
    # (선택) CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"], allow_credentials=True,
        allow_methods=["*"], allow_headers=["*"],
    )
    app.include_router(api_router)
    return app

app = create_app()
