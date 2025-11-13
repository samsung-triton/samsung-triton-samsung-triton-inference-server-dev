from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ServerStatusResponse(BaseModel):
    status: str = Field(..., example="ready")
    started_at: Optional[datetime] = None

class ServerActorRequest(BaseModel):
    user_login_id: str
    description: str | None = None 