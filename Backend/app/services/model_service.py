from typing import Dict, Any, List
from fastapi import UploadFile
from pathlib import Path
import shutil
import re
from app.clients.triton_client import triton_client
from app.schemas.model_schema import ModelRegisterRequest


def list_models_wrapped() -> Dict[str, Any]:
    models = triton_client.list_models()
    return {"code": "MODEL-001", "message": "모델 목록을 성공적으로 조회했습니다.", "data": {"models": models}}


# 안전한 파일/폴더명 치환: 영문, 숫자, ._- 만 허용
SAFE_NAME_RE = re.compile(r"[^a-zA-Z0-9_.\-]+")


def _safe_name(name: str) -> str:
    return SAFE_NAME_RE.sub("_", name.strip())


def _save_stream(dst: Path, up: UploadFile) -> int:
    """업로드 스트림을 파일로 저장(대용량 안전).
    - shutil.copyfileobj 로 chunk 복사 → 메모리 과점유 방지
    - 반환: 저장된 파일 크기(byte)
    """
    dst.parent.mkdir(parents=True, exist_ok=True)
    with dst.open("wb") as w:
        shutil.copyfileobj(up.file, w)
    return dst.stat().st_size


def register_model_service(
    req: ModelRegisterRequest, model_files: List[UploadFile], config_file: UploadFile
) -> Dict[str, Any]:
    """
    업로드 받은 파일들을 로컬 윈도우 **Downloads\\ex** 폴더에 저장.

    저장 규칙
    ---------
    - 루트:  {HOME}\\Downloads\\ex\\<modelName>
    - 버전:  항상 "1" 폴더 ⇒ {HOME}\\Downloads\\ex\\<modelName>\\1
    - config.pbtxt: 루트에 저장 ⇒ {HOME}\\Downloads\\ex\\<modelName>\\config.pbtxt
    - modelFiles: **모두** 1/ 폴더에 저장 (확장자 검증/분류 없음)
    - 같은 이름 존재 시 덮어쓰기
    """

    # 필수 파일 체크
    if model_files is None:
        raise ValueError("모델 파일(.onnx, .plan 등)이 필요합니다.")
    if config_file is None:
        raise ValueError("config.pbtxt 파일이 필요합니다.")

    # 경로 계산: {HOME}\Downloads\ex\<name>\1
    home = Path.home()
    save_root = home / "Downloads" / "ex"  # 고정 경로 (요청)

    # 모델 폴더명도 안전 치환
    model_name = _safe_name(req.modelName)
    model_root = save_root / model_name
    version_dir = model_root / "1"  # 항상 1 (요청)

    # 디렉토리 생성(존재해도 OK)
    model_root.mkdir(parents=True, exist_ok=True)
    version_dir.mkdir(parents=True, exist_ok=True)

    saved_files = []

    # 1) config.pbtxt는 루트에 저장
    cfg_name_on_req = config_file.filename or "config.pbtxt"
    cfg_name = "config.pbtxt" if cfg_name_on_req.lower() == "config.pbtxt" else _safe_name(cfg_name_on_req)
    cfg_path = model_root / cfg_name
    config_file.file.seek(0)
    size = _save_stream(cfg_path, config_file)
    saved_files.append(
        {
            "fileName": cfg_name,
            "filePath": str(cfg_path),
            "fileType": "CONFIG",  # (표시만, 분류 로직 없음)
            "sizeBytes": size,
        }
    )

    # 2) modelFiles: 전부 1/ 폴더로 저장 (검증/분류 X)
    for f in model_files:
        raw_name = f.filename
        fname = _safe_name(raw_name)
        dst = version_dir / fname
        f.file.seek(0)
        size = _save_stream(dst, f)
        saved_files.append(
            {
                "fileName": fname,
                "filePath": str(dst),
                "fileType": "OTHER",  # (표시만, 분류 로직 없음)
                "sizeBytes": size,
            }
        )

    return {
        "code": "MODEL-201",
        "message": "모델 등록 요청을 접수했습니다.",
        "data": {
            "modelName": req.modelName,
            "modelType": req.modelType.value,
            "description": req.description,
            "userId": req.userId,
            # "files": {"modelFile": [f.filename for f in model_files], "configFile": config_file.filename},
            "files": saved_files,
        },
    }
