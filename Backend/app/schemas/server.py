from pydantic import BaseModel
from typing import List

class HealthSummaryRes(BaseModel):
    live: bool
    ready: bool
    server: dict  # {"name": str, "version": str}

class ServerMetadataRes(BaseModel):
    name: str
    version: str
    extensions: List[str] = []

class ModelReadyReq(BaseModel):
    version: str | None = None

class ModelReadyRes(BaseModel):
    name: str
    version: str
    ready: bool
