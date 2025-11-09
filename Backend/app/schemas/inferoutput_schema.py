from pydantic import BaseModel, Field


class SaveInferenceResultRequest(BaseModel):
    uid: str = Field(..., min_length=1, description="사용자가 입력한 마스터키")
    result: str = Field(..., min_length=1, description="추론 결과")
