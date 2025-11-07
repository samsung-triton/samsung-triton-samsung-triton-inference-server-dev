from fastapi import APIRouter

from app.api.v1.user_router import user_router

from app.api.v1.masterkey_router import mastekey_router

from app.api.v1.server_router import server_router

api_router = APIRouter()
api_router.include_router(user_router)
api_router.include_router(mastekey_router)
api_router.include_router(server_router)
