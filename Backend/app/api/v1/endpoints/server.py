from fastapi import APIRouter
from app.services.health_meta_service import HealthMetaService
from app.schemas.server import HealthSummaryRes, ServerMetadataRes

router = APIRouter(prefix="/server", tags=["server"])
svc = HealthMetaService()

@router.get("/health", response_model=HealthSummaryRes)
def health_summary():
    data = svc.health_summary()
    return HealthSummaryRes(**data)

@router.get("/metadata", response_model=ServerMetadataRes)
def server_metadata():
    data = svc.server_metadata()
    return ServerMetadataRes(**data)
