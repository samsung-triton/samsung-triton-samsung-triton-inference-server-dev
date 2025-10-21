from fastapi import APIRouter
from .endpoints import server, models

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(server.router)
api_router.include_router(models.router)
