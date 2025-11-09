from pydantic import BaseModel
from datetime import datetime

class ConfigResponse(BaseModel):
    configId: int
    version: int
    content: str
    createdBy: int | None 
    createdAt: datetime
