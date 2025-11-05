from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from app.services.model_service import list_models_wrapped

router = APIRouter(prefix="/api/v1/models", tags=["models"])

@router.get("", summary="모델 목록 (전체) 조회")
def list_models():
    try:
        return list_models_wrapped()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Triton gRPC error: {e}")
