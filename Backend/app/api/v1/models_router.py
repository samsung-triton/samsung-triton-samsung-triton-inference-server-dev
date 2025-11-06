from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from typing import List, Annotated
from app.services.model_service import list_models_wrapped, register_model_service
from app.schemas.model_schema import ModelRegisterRequest

router = APIRouter(prefix="/api/v1/models", tags=["models"])


@router.get("", summary="모델 목록 (전체) 조회")
def list_models():
    try:
        return list_models_wrapped()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Triton gRPC error: {e}")


@router.post("", summary="모델 최초 등록")
def register_model(
    req: Annotated[ModelRegisterRequest, Depends(ModelRegisterRequest.as_form)],
    modelFiles: List[UploadFile] = File(..., description="모델 파일들 (.onnx / .plan / .pt / .pth 등)"),
    configFile: UploadFile = File(..., description="Triton 설정 파일 (config.pbtxt)"),
):
    """
    업로드 받은 파일을 로컬 윈도우 Downloads\\ex 아래에 저장
    - 경로: {HOME}\\Downloads\\ex\\<modelName>\\(1|config.pbtxt)
    - 버전은 항상 1 폴더로 고정 (덮어쓰기 허용)
    - Triton 로드는 다음 단계에서 처리
    """
    try:
        return register_model_service(req=req, model_files=modelFiles, config_file=configFile)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"등록 실패: {str(e)}")
