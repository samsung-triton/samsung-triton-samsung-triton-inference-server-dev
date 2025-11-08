from typing import Dict, Any, List
from fastapi import UploadFile, status
from pathlib import Path
import shutil
import re
from sqlalchemy.orm import Session

from app.clients.triton_client import triton_client
from app.schemas.model_schema import ModelRegisterRequest
from app.core.config import settings
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.models.model_entities import (
    Model,
    ModelVersion,
    ModelVersionFile,
    ModelConfig,
    ModelRelease,
    ReleaseType,
    ReleaseAction,
)
from app.models.user import User

# =========================
# 공통 설정
# =========================
SAFE_NAME_RE = re.compile(r"[^a-zA-Z0-9_.\-]+")

MODEL_REPO_ROOT = Path(settings.TRITON_MODEL_REPO)


def _safe_name(name: str) -> str:
    return SAFE_NAME_RE.sub("_", name.strip())


def _save_stream(dst: Path, up: UploadFile) -> int:
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


# =========================
# 1. 모델 목록 조회
# =========================
def list_models_service() -> Dict[str, Any]:
    try:
        models = triton_client.list_models()

        return create_response(
            CustomCode.MODEL_001.value,
            Messages.MODEL_LIST_FETCH_SUCCESS.value,
            {"models": models},
        )

    except Exception as e:
        msg = str(e).lower()

        # 연결 실패/타임아웃 계열 → Triton NOT READY
        if "failed to connect" in msg or "connection refused" in msg or "unavailable" in msg or "timed out" in msg:
            raise CustomHTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                code=CustomCode.ERR_503.value,
                message=Messages.TRITON_NOT_READY.value,
                data={"detail": str(e)},
            )

        # 나머지는 일반적인 목록 조회 에러
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_LIST_FETCH_ERROR.value,
            data={"detail": str(e)},
        )


# =========================================================
# 2. 모델 파일 저장 및 DB 기록
# =========================================================
# def register_model_service에 쓰임
def save_to_local_model_repo(
    model_name: str,
    model_files: List[UploadFile],
    config_file: UploadFile,
) -> Dict[str, Any]:
    """
    디렉터리 구조:
      <MODEL_REPO_ROOT>/<modelName>/config.pbtxt
      <MODEL_REPO_ROOT>/<modelName>/1/<모델 파일들>
    """
    root_dir = MODEL_REPO_ROOT / model_name
    v1_dir = root_dir / "1"

    saved_files: List[dict] = []

    # config.pbtxt 저장 (이름 고정)
    try:
        cfg_path = root_dir / "config.pbtxt"
        _save_stream(cfg_path, config_file)
        saved_files.append({"fileName": "config.pbtxt", "filePath": str(cfg_path)})
    except Exception:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
        )

    # 2) 모델 파일 저장
    for f in model_files or []:
        if not f or not f.filename:
            raise CustomHTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                code=CustomCode.ERR_400.value,
                message=Messages.MODEL_REGISTER_INVALID_FILE_NAME.value,
            )

        fname = _safe_name(f.filename)
        if not fname:
            raise CustomHTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                code=CustomCode.ERR_400.value,
                message=Messages.MODEL_REGISTER_INVALID_FILE_NAME.value,
            )

        try:
            dst = v1_dir / fname
            _save_stream(dst, f)
            saved_files.append({"fileName": fname, "filePath": str(dst)})
        except Exception:
            raise CustomHTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                code=CustomCode.ERR_500.value,
                message=Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
            )

    return {
        "model_name": model_name,
        "remote_root": str(root_dir),
        "remote_v1": str(v1_dir),
        "saved_files": saved_files,
    }


# def register_model_service에 쓰임
def record_model_data(
    req: ModelRegisterRequest,
    model_name: str,
    saved_files_remote: List[dict],
    db: Session,
    config_content: str | None = None,
):
    """
    1) LoginId로 User 조회
    2) Model / ModelVersion / ModelFile insert
    3) DB commit
    """
    # 1. 유저 확인
    user = db.query(User).filter(User.login_id == req.LoginId).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )

    try:
        # 2-1. Model 생성
        model_root_path = f"/models/{model_name}"
        model = Model(
            name=model_name,
            type=req.modelType.value,
            storage_dir=str(model_root_path),
        )
        db.add(model)
        db.flush()  # model.id 확보

        # 2-2. ModelVersion 생성 (v1 고정)
        version = ModelVersion(
            model_id=model.model_id,
            version=1,
            created_by=user.user_id,
            # note="초기 등록 버전",
        )
        db.add(version)
        db.flush()  # version.id 확보

        # 2-3. ModelFile 생성
        config_file_abs = None
        for f in saved_files_remote:
            abs_path = Path(f["filePath"])
            mvf = ModelVersionFile(
                model_version_id=version.model_version_id,
                file_name=f["fileName"],
                file_path=str(abs_path),  # 절대경로 그대로
            )
            db.add(mvf)

            if f["fileName"] == "config.pbtxt":
                config_file_abs = str(abs_path)

        # 2-4 model_configs 등록
        # config_content가 파라미터로 들어오면 그걸 쓰고, 없으면 직접 읽어서 content 생성
        if config_file_abs:
            cfg_text = config_content
            if not cfg_text:
                try:
                    with Path(config_file_abs).open("r", encoding="utf-8", errors="ignore") as f:
                        cfg_text = f.read()
                except Exception:
                    raise CustomHTTPException(
                        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                        code=CustomCode.ERR_500.value,
                        message=Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
                    )

            model_config = ModelConfig(
                model_id=model.model_id,
                version=1,
                content=cfg_text,
                file_path=config_file_abs,  # 절대경로 저장
                created_by=user.user_id,
                is_current=True,
            )
            db.add(model_config)

        # 2-5 model_releases 테이블 등록 (모델 생성 로그)
        release = ModelRelease(
            actor_id=user.user_id,
            type=ReleaseType.MODEL,
            action=ReleaseAction.CREATE,
            target_id=model.model_id,
            reason="신규 모델 등록",
        )
        db.add(release)

        db.commit()
        db.refresh(model)
        db.refresh(version)

    except CustomHTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
        )

    # 3. 응답 데이터 구성
    files_resp = [
        {"fileName": f.file_name, "filePath": f.file_path}
        for f in db.query(ModelVersionFile).filter(ModelVersionFile.model_version_id == version.model_version_id).all()
    ]

    return {
        "model_id": model.model_id,
        "model_name": model.name,
        "files_resp": files_resp,
        "created_at_iso": version.created_at.isoformat() if version.created_at else "",
    }


def register_model_service(
    req: ModelRegisterRequest,
    model_files: List[UploadFile],
    config_file: UploadFile,
    db: Session,
) -> Dict[str, Any]:
    """
    1) 파일 업로드
    1-2) 모델 로드
    2) DB(models / model_versions / model_version_files / model_configs) 기록
    3) 지정한 응답 포맷으로 반환 (MODEL-002)
    """
    # 필수값 검증
    if not req.modelName or not req.modelType or not req.LoginId or not model_files or not config_file:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.MODEL_REGISTER_MISSING_REQUIRED.value,
        )

    # 모델명 확인
    model_name = _safe_name(req.modelName)
    if not model_name:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.MODEL_REGISTER_INVALID_NAME.value,
            data=None,
        )

    # 모델명 중복 체크
    exists = db.query(Model).filter(Model.name == model_name).first()
    if exists:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.MODEL_003.value,  # 중복 에러
            message=Messages.MODEL_REGISTER_DUPLICATE_NAME.value,
            data=None,
        )

    # 1) 파일 저장
    try:
        save_result = save_to_local_model_repo(
            model_name=model_name,
            model_files=model_files,
            config_file=config_file,
        )
    except CustomHTTPException:
        # save_to_local_model_repo 내부에서 이미 CustomHTTPException 발생 시 그대로 전파
        raise
    except Exception:
        # 예상치 못한 예외
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_REGISTER_UPLOAD_ERROR.value,
        )

    # 1-2) 트리톤 모델 로드
    try:
        triton_client.load_model(model_name=model_name)
    except Exception as e:
        # print(e)
        model_dir = Path(save_result["remote_root"])
        if model_dir.exists():
            shutil.rmtree(model_dir, ignore_errors=True)

        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_LOAD_ERROR.value,
            data=str(e),
        )

    # 2) DB 기록
    config_file.file.seek(0)
    config_text = config_file.file.read().decode("utf-8", errors="ignore")
    config_file.file.seek(0)

    dbres = record_model_data(
        req=req,
        model_name=model_name,
        saved_files_remote=save_result["saved_files"],
        db=db,
        config_content=config_text,
    )

    # 3) 응답 포맷(요구 스펙)
    data = {
        "modelId": dbres["model_id"],
        "modelName": dbres["model_name"],
        "modelType": str(req.modelType.value),
        "files": dbres["files_resp"],
        "description": req.description or "",
        "createdBy": req.LoginId,
        "createdAt": dbres["created_at_iso"],
    }

    return create_response(
        CustomCode.MODEL_002.value,
        Messages.MODEL_REGISTER_SUCCESS.value,
        data,
    )
