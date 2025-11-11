from fastapi import UploadFile, status
from pathlib import Path
from typing import List, Dict, Union
import shutil, zipfile, tempfile, os
import re

from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.core.config import settings
from fastapi import status


# ==============================
# 공통 설정
# ==============================
MODEL_REPO_ROOT = Path(settings.TRITON_MODEL_REPO)

# =====================================================
# 0. 안전한 파일/모델명 치환 (영문/숫자/_만 허용)
# =====================================================

SAFE_NAME_RE = re.compile(r"[^a-zA-Z0-9_.\-]+")


def safe_name(name: str) -> str:
    return SAFE_NAME_RE.sub("_", name.strip())


# =====================================================
# 1. 파일 스트림 저장 (대용량 안전)
# =====================================================
def save_stream(dst: Path, up: UploadFile) -> int:
    """
    UploadFile 스트림을 로컬 파일로 저장.
    - chunk 단위 복사로 대용량 안전
    - 반환: 저장된 파일 크기(byte)
    """
    dst.parent.mkdir(parents=True, exist_ok=True)
    up.file.seek(0)
    with dst.open("wb") as f:
        shutil.copyfileobj(up.file, f)
    return dst.stat().st_size


# =====================================================
# 2. config.pbtxt 저장
# =====================================================
def save_model_config_file(model_name: str, config_file: UploadFile) -> Path:
    """config.pbtxt 저장 및 경로 반환"""

    root_dir = MODEL_REPO_ROOT / model_name
    cfg_path = root_dir / "config.pbtxt"
    try:
        save_stream(cfg_path, config_file)
    except Exception:
        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
        )
    return cfg_path


# =====================================================
# 3. 모델 파일 저장 (ZIP 포함 가능)
# =====================================================
def store_model_files(model_name: str, version: int, model_files: List[UploadFile]) -> List[Dict[str, str]]:
    """
    모델 파일 저장 (ZIP 및 일반 파일 모두 지원)
    - /models/{model_name}/{version}/ 내부에 직접 저장
    - ZIP 파일이면 자동 압축 해제
    - 반환: DB 기록용 [{fileName, filePath}]
    """
    base_dir = Path(settings.TRITON_MODEL_REPO) / model_name / str(version)
    base_dir.mkdir(parents=True, exist_ok=True)

    saved_files = []

    for file in model_files:
        if not file or not file.filename:
            continue

        filename = safe_name(file.filename)

        # (1) ZIP 파일 처리
        if filename.lower().endswith(".zip"):
            zip_path = base_dir / filename

            # zip을 base_dir 내부에 직접 저장
            with open(zip_path, "wb") as f:
                shutil.copyfileobj(file.file, f)

            # 유효한 zip인지 검사
            if not zipfile.is_zipfile(zip_path):
                raise CustomHTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    code=CustomCode.ERR_400.value,
                    message=Messages.INVALID_ARCHIVE_FORMAT.value,
                )
            
            # 압축 해제
            with zipfile.ZipFile(zip_path, "r") as zip_ref:
                # 공통 접두 디렉토리 추출 (예: yolotiny_onnx/1/)
                common_prefix = os.path.commonprefix(zip_ref.namelist())
                
                for member in zip_ref.infolist():
                    if member.is_dir():
                        continue

                    # 상대경로 계산: 상위 불필요한 폴더 제거
                    rel_path = os.path.relpath(member.filename, common_prefix)
                    target_path = base_dir / rel_path
                    target_path.parent.mkdir(parents=True, exist_ok=True)

                    # 파일 추출
                    with zip_ref.open(member, "r") as src, open(target_path, "wb") as dst:
                        dst.write(src.read())

            # zip 파일은 삭제 가능
            zip_path.unlink(missing_ok=True)

            # 압축 해제된 파일들 저장 정보 수집
            for p in base_dir.rglob("*"):
                if p.is_file():
                    rel_path = p.relative_to(base_dir)
                    saved_files.append({"fileName": str(rel_path), "filePath": str(p)})

        # (2) 일반 파일 처리
        else:
            dst = base_dir / filename
            save_stream(dst, file)
            saved_files.append({"fileName": filename, "filePath": str(dst)})

    return saved_files
