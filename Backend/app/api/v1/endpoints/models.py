from fastapi import APIRouter, Query
from app.services.health_meta_service import HealthMetaService
from app.schemas.server import ModelReadyRes

router = APIRouter(prefix="/models", tags=["models"])
svc = HealthMetaService()

@router.get("/{name}/ready", response_model=ModelReadyRes)
def model_ready(name: str, version: str | None = Query(default=None)):
    ready = svc.model_ready(name, version)
    return ModelReadyRes(name=name, version=(version or ""), ready=ready)
