# app/services/model_service.py
from typing import Dict, Any
from app.clients.triton_client import triton_client

def list_models_wrapped() -> Dict[str, Any]:
    models = triton_client.list_models()
    return {
        "code": "MODEL-001",
        "message": "모델 목록을 성공적으로 조회했습니다.",
        "data": {
            "models": models
        }
    }
