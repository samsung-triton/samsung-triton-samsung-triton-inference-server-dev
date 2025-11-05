from pydantic import BaseModel, Field


class MasterKeyConfirmRequest(BaseModel):
    masterKey: str = Field(..., description="사용자가 입력한 마스터키")
