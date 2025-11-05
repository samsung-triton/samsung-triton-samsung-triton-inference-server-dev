from fastapi import APIRouter
from .models_router import router as models_router

api_router = APIRouter()
api_router.include_router(models_router)