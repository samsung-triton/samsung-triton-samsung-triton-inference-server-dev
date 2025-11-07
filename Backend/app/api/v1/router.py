from fastapi import APIRouter

from app.api.v1.user_router import user_router
from app.api.v1.masterkey_router import mastekey_router
from app.api.v1.interdata_router import inferdata_router

api_router = APIRouter()  # /api/v1 라우터 묶기
api_router.include_router(user_router)
api_router.include_router(mastekey_router)
api_router.include_router(inferdata_router)
