from fastapi import APIRouter
from app.api.v1.user_router import user_router
from app.api.v1.masterkey_router import mastekey_router
from app.api.v1.inferdata_router import inferdata_router
from app.api.v1.server_router import server_router
from app.api.v1.metrics_router import metrics_router

api_router = APIRouter()  # /api/v1 라우터 묶기
api_router.include_router(user_router)
api_router.include_router(mastekey_router)
api_router.include_router(inferdata_router)
api_router.include_router(server_router)
api_router.include_router(metrics_router)
