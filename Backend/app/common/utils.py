import shutil
import zipfile
import tarfile
import os
import re
from sqlalchemy.orm import Session
from fastapi import status, UploadFile
from pathlib import Path
from typing import List, Dict
from datetime import datetime

from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.models.user import User
from app.core.config import settings, TIMEZONE
from app.core.logger import extract_error


def get_user_or_404(db: Session, login_id: str) -> User:
    # 사용자 조회
    user = db.query(User).filter(User.login_id == login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )
    return user


# ==============================
# 공통 설정
# ==============================
MODEL_REPO_ROOT = Path(settings.TRITON_MODEL_PATH)

# =====================================================
# 안전한 파일/모델명 치환 (영문/숫자/_만 허용)
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
# 압축 풀기
# =====================================================
def _extract_zip(zip_path: Path, base_dir: Path):
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        # 디렉토리 제외한 "실제 파일" 목록
        file_members = [m for m in zip_ref.infolist() if not m.is_dir()]

        # 파일이 1개일 때는 그냥 그 파일 이름 그대로 쓰기 (common_prefix X)
        if len(file_members) == 1:
            member = file_members[0]
            rel_path = member.filename  # 'config.pbtxt' 같은 것
            target_path = base_dir / rel_path
            target_path.parent.mkdir(parents=True, exist_ok=True)
            with zip_ref.open(member, "r") as src, open(target_path, "wb") as dst:
                dst.write(src.read())
            return

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
        file_members = [m for m in tar_ref.getmembers() if m.isfile()]

        if len(file_members) == 1:
            member = file_members[0]
            rel_path = member.name
            target_path = base_dir / rel_path
            target_path.parent.mkdir(parents=True, exist_ok=True)
            with tar_ref.extractfile(member) as src, open(target_path, "wb") as dst:
                shutil.copyfileobj(src, dst)
            return

        try:
            common_prefix = os.path.commonpath([m.name for m in file_members])
        except ValueError:
            common_prefix = ""

        for member in file_members:
            try:
                rel_path = os.path.relpath(member.name, common_prefix)
            except ValueError:
                rel_path = member.name

            target_path = base_dir / rel_path
            target_path.parent.mkdir(parents=True, exist_ok=True)

            with tar_ref.extractfile(member) as src, open(target_path, "wb") as dst:
                shutil.copyfileobj(src, dst)


def _is_conda_pack_filename(lower_name: str) -> bool:
    # 소문자 기준 python*.tar.gz → conda-pack 간주(압축 해제 X)
    return lower_name.startswith("python") and lower_name.endswith(".tar.gz")


# =====================================================
# 2. config.pbtxt 저장
# =====================================================
def save_model_config_file(model_name: str, config_file: UploadFile) -> List[Dict[str, str]]:
    """
    설정 파일 저장:
      - config.pbtxt(단일)  → 모델 루트에 저장 후 경로 반환
      - zip/tar(.gz)/tgz   → 임시로 풀어 'config.pbtxt' 탐색, 찾으면 루트에 배치 후 경로 반환
      - 소문자 python*.tar.gz → conda-pack으로 간주, '추출하지 않고' 루트에 그대로 저장 후 그 경로 반환
        (주의: 이 경우 반환 파일은 config.pbtxt가 아님. 상위 서비스에서 텍스트 읽기 전에 확장자 체크 필요)
    """

    model_root = MODEL_REPO_ROOT / model_name
    model_root.mkdir(parents=True, exist_ok=True)

    fname = safe_name(config_file.filename)
    lower = fname.lower()
    dst = model_root / fname
    save_stream(dst, config_file)

    saved_files: List[Dict[str, str]] = []

    # 1) config.pbtxt 단일
    if lower.endswith("config.pbtxt"):
        saved_files = [{"fileName": "config.pbtxt", "filePath": str(dst)}]
        return saved_files

    # 2) conda-pack (python*.tar.gz) → 압축 해제하지 않고 그대로 반환
    if _is_conda_pack_filename(lower):
        saved_files = [{"fileName": fname, "filePath": str(dst)}]
        return saved_files

    # 3) 일반 압축 파일(.zip, .tar, .tar.gz, .tgz)은 model_root에 바로 해제
    try:
        if zipfile.is_zipfile(dst):
            _extract_zip(dst, model_root)
            dst.unlink(missing_ok=True)
        elif tarfile.is_tarfile(dst):
            _extract_tar(dst, model_root)
            dst.unlink(missing_ok=True)
        else:
            raise CustomHTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                code=CustomCode.ERR_400.value,
                message=Messages.INVALID_ARCHIVE_FORMAT.value,
            )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.ARCHIVE_EXTRACTION_ERROR.value,
            data={"error": extract_error(e)},
        )

    # # 4) 압축 해제 후 model_root 바로 아래 파일만 수집
    for p in model_root.iterdir():
        if p.is_file():
            saved_files.append({"fileName": p.name, "filePath": str(p)})

    return saved_files


# =====================================================
# 3. 모델 파일 저장 (ZIP, TAR 포함 가능)
# =====================================================
def save_model_file(model_name: str, version: int, model_file: UploadFile) -> List[Dict[str, str]]:
    """
    모델 파일 저장 (ZIP, TAR.GZ, TAR 및 일반 파일 지원)
    - /models/{model_name}/{version}/ 내부에 직접 저장
    - ZIP 파일이면 자동 압축 해제
    - 반환: DB 기록용 [{fileName, filePath}]
    """
    model_root = MODEL_REPO_ROOT / model_name
    version_dir = model_root / str(version)
    version_dir.mkdir(parents=True, exist_ok=True)

    if not model_file:
        return []

    # 일단 파일 등록
    fname = safe_name(model_file.filename)
    lower = fname.lower()
    dst = version_dir / fname
    save_stream(dst, model_file)

    # 압축이면 해제
    try:
        if zipfile.is_zipfile(dst):
            _extract_zip(dst, version_dir)
            dst.unlink(missing_ok=True)
        elif tarfile.is_tarfile(dst):
            _extract_tar(dst, version_dir)
            dst.unlink(missing_ok=True)
        elif lower.endswith((".zip", ".tar", ".tar.gz", ".tgz")):
            raise CustomHTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                code=CustomCode.ERR_400.value,
                message=Messages.INVALID_ARCHIVE_FORMAT.value,
            )
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.ARCHIVE_EXTRACTION_ERROR.value,
            data={"error": extract_error(e)},
        )

    # 파일 목록 수집 (버전 디렉토리 기준 상대경로)
    out: List[Dict[str, str]] = []
    for p in version_dir.rglob("*"):
        if p.is_file():
            rel = p.relative_to(version_dir)
            out.append({"fileName": str(rel), "filePath": str(p)})
    return out


def to_utc_z(ts) -> str:
    """
    아무 타입이나 들어와도 UTC 기준 ISO8601 Z 형식으로 변환:
    예) 2025-11-27T10:00:00Z
    """
    if isinstance(ts, datetime):
        # tz 정보 없으면 UTC라고 가정
        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=TIMEZONE)

        # 혹시 다른 타임존이면 UTC로 변환
        ts_utc = ts.astimezone(TIMEZONE)

        # 마이크로초 제거 + Z 형식으로 고정
        return ts_utc.strftime("%Y-%m-%dT%H:%M:%SZ")

    # datetime 이 아니면 그냥 문자열로
    return str(ts)
