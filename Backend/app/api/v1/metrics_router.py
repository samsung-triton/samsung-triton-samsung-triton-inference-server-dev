from fastapi import APIRouter


metrics_router = APIRouter(prefix="/api/v1/dashboard/server/metrics", tags=["Metircs"])
