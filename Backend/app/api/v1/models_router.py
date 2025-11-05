from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from app.clients.triton_client import triton_client

router = APIRouter(prefix="/api/v1/models", tags=["models"])

@router.get("", summary="모델 목록 (전체)")
def list_models():
    try:
        return triton_client.list_models()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Triton gRPC error: {e}")
