from pydantic import BaseModel, Field


class SaveInferenceResultRequest(BaseModel):
    uid: str = Field(..., min_length=1, description="추론 요청 고유 ID")
    is_ok: bool = Field(..., description="모델 추론 결과 (True=OK, False=NG)")
    result: str = Field(..., min_length=1, description="추론 결과")
