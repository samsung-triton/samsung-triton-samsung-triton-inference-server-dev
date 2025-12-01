from pydantic import Field
from app.schemas.base_schema import BaseRequest


class MasterKeyVarifyRequest(BaseRequest):
    master_key: int = Field(..., description="사용자가 입력한 마스터키")
