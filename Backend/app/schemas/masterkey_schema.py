from pydantic import BaseModel, Field


class MasterKeyVarifyRequest(BaseModel):
    masterKey: int = Field(..., description="사용자가 입력한 마스터키")
