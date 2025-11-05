from fastapi import APIRouter

# 라우터 추가 시
# from .models_router import router as models_router
from app.api.v1.user_router import user_router

api_router = APIRouter()
api_router.include_router(user_router)
# api_router.include_router(models_router)
