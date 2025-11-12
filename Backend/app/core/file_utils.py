from fastapi import UploadFile, status
from pathlib import Path
from typing import List, Dict, Union
import shutil, zipfile, tarfile, os
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
# 3. 모델 파일 저장 (ZIP, TAR 포함 가능)
# =====================================================

def _extract_zip(zip_path: Path, base_dir: Path):
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        # 공통 경로 추출
        try:
            common_prefix = os.path.commonpath(zip_ref.namelist())
        except ValueError:
            common_prefix = ""
        
        # ZIP 내 모든 파일 반복
        for member in zip_ref.infolist():
            if member.is_dir(): 
                continue

            try:
                rel_path = os.path.relpath(member.filename, common_prefix)
            except ValueError:
                rel_path = member.filename

            target_path = base_dir / rel_path
            target_path.parent.mkdir(parents=True, exist_ok=True)
            
            # 파일 바이너리 그대로 복사
            with zip_ref.open(member, "r") as src, open(target_path, "wb") as dst:
                dst.write(src.read())


def _extract_tar(tar_path: Path, base_dir: Path):
    with tarfile.open(tar_path, "r:*") as tar_ref:
        members = [m for m in tar_ref.getmembers() if m.isfile()]
        try:
            common_prefix = os.path.commonpath([m.name for m in members])
        except ValueError:
            common_prefix = ""

        for member in members:
            try:
                rel_path = os.path.relpath(member.name, common_prefix)
            except ValueError:
                rel_path = member.name

            target_path = base_dir / rel_path
            target_path.parent.mkdir(parents=True, exist_ok=True)
            with tar_ref.extractfile(member) as src, open(target_path, "wb") as dst:
                shutil.copyfileobj(src, dst)


def store_model_files(model_name: str, version: int, model_files: List[UploadFile]) -> List[Dict[str, str]]:
    """
    모델 파일 저장 (ZIP, TAR.GZ, TAR 및 일반 파일 지원)
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
        dst_path = base_dir / filename
        
        # 압축파일 저장
        with open(dst_path, "wb") as f:
            shutil.copyfileobj(file.file, f)

        # ZIP
        if zipfile.is_zipfile(dst_path):
            _extract_zip(dst_path, base_dir)
            dst_path.unlink(missing_ok=True)

        # TAR / TAR.GZ
        elif tarfile.is_tarfile(dst_path):
            _extract_tar(dst_path, base_dir)
            dst_path.unlink(missing_ok=True)

        # 유효하지 않은 압축파일 (.zip으로 끝나는데 실제 zip 아님 등)
        elif filename.lower().endswith((".zip", ".tar", ".tar.gz", ".tgz")):
            raise CustomHTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                code=CustomCode.ERR_400.value,
                message=Messages.INVALID_ARCHIVE_FORMAT.value,
            )

        # 일반 파일
        else:
            saved_files.append({"fileName": filename, "filePath": str(dst_path)})

        # 압축파일 처리 후 파일 수집
        for p in base_dir.rglob("*"):
            if p.is_file():
                rel_path = p.relative_to(base_dir)
                saved_files.append({"fileName": str(rel_path), "filePath": str(p)})

    return saved_files
