from collections import defaultdict
from typing import Dict, Any, List
from fastapi import UploadFile, status
from pathlib import Path
import shutil
import re
from sqlalchemy.orm import Session
import os

from app.clients.triton_client import triton_client
from app.schemas.model_schema import ModelRegisterRequest, ModelDeleteRequest
from app.core.config import settings
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.models.model import (
    Model,
    ModelVersion,
    ModelVersionFile,
    ModelRelease,
    ReleaseType,
    ReleaseAction,
)
from app.models.model_config import ModelConfig
from app.models.user import User
from app.core.file_utils import safe_name, save_model_config_file, store_model_files

# =========================
# 공통 설정
# =========================
MODEL_REPO_ROOT = Path(settings.TRITON_MODEL_REPO)


# =====================================================
# DB 관련 함수
# =====================================================
def _get_user_or_404(db: Session, login_id: str) -> User:
    user = db.query(User).filter(User.login_id == login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )
    return user


def _save_model(db: Session, name: str, model_type: str, storage_dir: str) -> Model:
    model = Model(name=name, type=model_type, storage_dir=storage_dir)
    db.add(model)
    db.flush()
    return model


def _save_model_version(
    db: Session, model_id: int, user_id: int, version_num: int, represent_file: str
) -> ModelVersion:
    version = ModelVersion(
        model_id=model_id, version=version_num, represent_file_name=represent_file, created_by=user_id
    )
    db.add(version)
    db.flush()
    return version


def _save_version_file(db: Session, version_id: int, file_name: str, file_path: str) -> ModelVersionFile:
    mvf = ModelVersionFile(model_version_id=version_id, file_name=file_name, file_path=file_path)
    db.add(mvf)
    db.flush()
    return mvf


def save_model_config(db: Session, model_id: int, version: int, content: str, file_path: str, user_id: int):
    cfg = ModelConfig(
        model_id=model_id,
        version=version,
        content=content,
        file_path=file_path,
        created_by=user_id,
        is_current=True,
    )
    db.add(cfg)
    db.flush()
    return cfg


def save_model_release(
    db: Session, actor_id: int, type_: ReleaseType, action_: ReleaseAction, target_id: int, reason: str
):
    release = ModelRelease(
        actor_id=actor_id,
        type=type_,
        action=action_,
        target_id=target_id,
        reason=reason,
    )
    db.add(release)
    db.flush()
    return release


# =========================
# 1. 모델 목록 조회
# =========================
def list_models_service(db: Session) -> Dict[str, Any]:
    try:
        resp = triton_client.list_models()

        triton_models = resp.get("models", [])
        if not isinstance(triton_models, list):
            triton_models = []

        # 모델 이름별로 버전 묶기
        triton_grouped = defaultdict(list)
        for m in triton_models:
            triton_grouped[m["name"]].append(m)

        # DB 모델 데이터 조회
        db_models = db.query(Model).all()

        # response data 변환
        result = []
        for model in db_models:
            model_id = model.model_id
            name = model.name
            type = model.type
            total_versions = db.query(ModelVersion).filter(ModelVersion.model_id == model_id).count()

            # 상태 확인
            versions = triton_grouped.get(name, [])
            ready_versions = [v for v in versions if v.get("state") == "READY"]

            if ready_versions:
                status_bool = True
                last_loaded = max(int(v["version"]) for v in ready_versions)
            else:
                status_bool = False
                last_loaded = "N/A"

            result.append(
                {
                    "modelId": model_id,
                    "name": name,
                    "type": type,
                    "status": status_bool,  # True / False
                    "lastLoadedVersion": last_loaded,  # "4" or "N/A"
                    "totalVersions": total_versions,  # from DB
                }
            )

        return create_response(
            CustomCode.MODEL_001.value,
            Messages.MODEL_LIST_FETCH_SUCCESS.value,
            {"models": result},
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
# 2. 일반 모델 최초 등록
# =========================================================

MODEL_EXTS = [".onnx", ".pt", ".pth", ".pb", ".plan", ".trt", ".py"]


def _choose_represent_file(file_names: list[str]) -> str | None:
    # config.pbtxt 제외, 확장자 필터, 'model' 포함, 첫 번째만 선택
    if not file_names:
        return None

    valid_files = [f for f in file_names if "config.pbtxt" not in f.lower()]
    if not valid_files:
        return None

    model_files = [f for f in valid_files if os.path.splitext(f)[1].lower() in MODEL_EXTS]
    if not model_files:
        return None

    model_named = [f for f in model_files if "model" in f.lower()]  # 경로 전체에 'model'이 포함된 경우도 인식

    if model_named:
        return model_named[0]
    return model_files[0]


def register_model_service(
    req: ModelRegisterRequest,
    model_file: UploadFile,
    config_file: UploadFile,
    db: Session,
) -> Dict[str, Any]:
    """단일 모델 등록 서비스"""
    # 필수값 검증
    # if not req.modelName or not req.modelType or not req.LoginId or not model_files or not config_file:
    if not model_file or not config_file:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.MODEL_REGISTER_MISSING_REQUIRED.value,
        )

    # 모델명 확인
    model_name = safe_name(req.modelName)
    if not model_name:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.MODEL_REGISTER_INVALID_NAME.value,
        )

    # 모델명 중복 체크
    exists = db.query(Model).filter(Model.name == model_name).first()
    if exists:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.MODEL_003.value,  # 중복 에러
            message=Messages.MODEL_REGISTER_DUPLICATE_NAME.value,
        )

    # 1) 파일 저장
    saved_model_files = store_model_files(model_name, 1, model_files)
    cfg_path = save_model_config_file(model_name, config_file)

    file_names = [f["fileName"] for f in saved_model_files]
    represent_file = _choose_represent_file(file_names)  # 대표 파일명 자동 선택

    saved_files = [{"fileName": "config.pbtxt", "filePath": str(cfg_path)}] + saved_model_files

    # 2) 트리톤 모델 로드
    try:
        triton_client.load_model(model_name=model_name)
    except Exception as e:
        shutil.rmtree(MODEL_REPO_ROOT / model_name, ignore_errors=True)

        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_LOAD_ERROR.value,
            data=str(e),
        )

    # 3) DB 기록
    user = _get_user_or_404(db, req.LoginId)
    config_text = cfg_path.read_text(encoding="utf-8", errors="ignore")

    try:
        model = _save_model(db, model_name, req.modelType.value, str(MODEL_REPO_ROOT / model_name))
        version = _save_model_version(db, model.model_id, user.user_id, 1, represent_file)
        for f in saved_files:
            _save_version_file(db, version.model_version_id, f["fileName"], f["filePath"])
        save_model_config(db, model.model_id, 1, config_text, str(cfg_path), user.user_id)
        save_model_release(
            db,
            actor_id=user.user_id,
            type_=ReleaseType.MODEL,
            action_=ReleaseAction.CREATE,
            target_id=model.model_id,
            reason=req.description or "신규 모델 등록",
        )

        db.commit()
    except Exception as e:
        db.rollback()  # 모든 변경사항 롤백
        triton_client.unload_model(model_name=model_name)
        shutil.rmtree(MODEL_REPO_ROOT / model_name, ignore_errors=True)

        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.MODEL_REGISTER_DB_ERROR.value,
            str(e),
        )

    return create_response(
        CustomCode.MODEL_002.value,
        Messages.MODEL_REGISTER_SUCCESS.value,
        {
            "modelId": model.model_id,
            "modelName": model.name,
            "modelType": req.modelType.value,
            "files": saved_files,
            # "description": req.description,
            # "createdBy": req.LoginId,
            "createdAt": version.created_at.isoformat(),
        },
    )


# =====================================================
# 3. 앙상블 모델 등록
# =====================================================
def register_ensemble_service(req: ModelRegisterRequest, config_file: UploadFile, db: Session):
    # 필수값 검증
    if not req.modelName or not req.modelType or not req.LoginId or not config_file:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.ENSEMBLE_REGISTER_MISSING_REQUIRED.value,
        )

    # 모델명 확인
    model_name = safe_name(req.modelName)
    exists = db.query(Model).filter(Model.name == model_name).first()
    if exists:
        raise CustomHTTPException(
            status_code=status.HTTP_409_CONFLICT,
            code=CustomCode.ERR_409.value,
            message=Messages.ENSEMBLE_REGISTER_DUPLICATE_NAME.value,
        )

    # === 1. config 랑 폴더 저장 ===
    cfg_path = save_model_config_file(model_name, config_file)
    config_text = cfg_path.read_text(encoding="utf-8", errors="ignore")
    store_model_files(model_name, 1, [])

    # === 2. 트리톤 모델 로드
    try:
        triton_client.load_model(model_name=model_name)
    except Exception as e:
        shutil.rmtree(MODEL_REPO_ROOT / model_name, ignore_errors=True)

        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_LOAD_ERROR.value,
            data=str(e),
        )

    # === 3. DB 기록 ===
    user = _get_user_or_404(db, req.LoginId)

    try:
        model = _save_model(db, model_name, "ENSEMBLE", str(MODEL_REPO_ROOT / model_name))
        version = _save_model_version(db, model.model_id, user.user_id, 1, None)
        _save_version_file(db, version.model_version_id, "config.pbtxt", str(cfg_path))
        save_model_config(db, model.model_id, 1, config_text, str(cfg_path), user.user_id)
        save_model_release(
            db,
            actor_id=user.user_id,
            type_=ReleaseType.MODEL,
            action_=ReleaseAction.CREATE,
            target_id=model.model_id,
            reason=req.description or "신규 앙상블 모델 등록",
        )

        db.commit()

    except Exception as e:
        db.rollback()
        triton_client.unload_model(model_name=model_name)
        shutil.rmtree(MODEL_REPO_ROOT / model_name, ignore_errors=True)
        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.MODEL_REGISTER_DB_ERROR.value,
            str(e),
        )

    return create_response(
        CustomCode.MODEL_003.value,
        Messages.ENSEMBLE_REGISTER_SUCCESS.value,
        {
            "modelId": model.model_id,
            "modelName": model.name,
            "modelType": req.modelType.value,
            "filePath": str(cfg_path),
            # "description": req.description,
            # "createdBy": req.LoginId,
            "createdAt": version.created_at.isoformat(),
        },
    )


# =====================================================
# 4. 모델 관련 파일 추가
# =====================================================
def register_model_assets_service(
    model_id: int, login_id: str, description: str, model_files: UploadFile, config_file: UploadFile, db: Session
):
    # === 1. 모델, 유저 검증 & 버전 계산 ===
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.MODEL_NOT_FOUND_FOUND.value,
        )

    user = _get_user_or_404(db, login_id)

    next_version = (model.last_version_num or 1) + 1

    # === 2. 모델 파일 저장 ===
    saved_files = store_model_files(model.name, next_version, model_files)

    file_names = [f["fileName"] for f in saved_files]
    represent_file = _choose_represent_file(file_names)  # 대표 파일명 자동 선택

    # === 3. Triton 재로드 ===
    try:
        triton_client.unload_model(model_name=model.name)
        triton_client.load_model(model_name=model.name)
    except Exception as e:
        # 로드 실패 → 방금 생성된 버전 폴더 삭제
        vdir = MODEL_REPO_ROOT / model.name / str(next_version)
        if vdir.exists():
            shutil.rmtree(vdir, ignore_errors=True)

        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.MODEL_LOAD_ERROR.value,
            data={"detail": str(e)},
        )

    # === 3. DB 기록 ===
    try:
        version = _save_model_version(db, model_id, user.user_id, next_version, represent_file)
        for f in saved_files:
            _save_version_file(db, version.model_version_id, f["fileName"], f["filePath"])
        save_model_release(
            db, user.user_id, ReleaseType.VERSION, ReleaseAction.CREATE, model_id, description or "모델 버전 추가"
        )

        model.last_version_num = next_version

        db.commit()

    except Exception as e:
        db.rollback()
        triton_client.unload_model(model_name=model.name)
        vdir = MODEL_REPO_ROOT / model.name / str(next_version)
        if vdir.exists():
            shutil.rmtree(vdir, ignore_errors=True)

        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            message=Messages.MODEL_REGISTER_DB_ERROR.value,
            data=str(e),
        )

    return create_response(
        CustomCode.MODEL_004.value,
        Messages.MODEL_VERSION_ADD_SUCCESS.value,
        {
            "modelId": model_id,
            "version": next_version,
            "files": saved_files,
            # "description": description,
            # "createdBy": login_id,
            "createdAt": version.created_at.isoformat(),
        },
    )


# =====================================================
# 5. 모델 버전 삭제
# =====================================================
def _delete_version_files_and_db(model, version: int, db: Session):
    try:
        version_obj = (
            db.query(ModelVersion)
            .filter(ModelVersion.model_id == model.model_id, ModelVersion.version == version)
            .first()
        )
        if not version_obj:
            raise CustomHTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                code=CustomCode.ERR_404.value,
                message=Messages.MODEL_VERSION_NOT_FOUND.value,
            )

        db.delete(version_obj)
        db.commit()

    except Exception as e:
        db.rollback()
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_DELETE_DB_ERROR.value,
            data=str(e),
        )

    # 파일 삭제 (DB 성공 후만 수행)
    vdir = MODEL_REPO_ROOT / model.name / str(version)
    if vdir.exists():
        shutil.rmtree(vdir, ignore_errors=True)
    else:
        # 파일이 없는 경우는 무시 (추후 로그 남길 수 있음)
        pass


def delete_model_version_service(model_id: int, version: int, req: ModelDeleteRequest, db: Session):
    # === 1. 모델, 버전, 유저 검증 ===
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.MODEL_NOT_FOUND_FOUND.value,
        )

    user = _get_user_or_404(db, req.loginId)

    version_obj = (
        db.query(ModelVersion).filter(ModelVersion.model_id == model_id, ModelVersion.version == version).first()
    )
    if not version_obj:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.MODEL_VERSION_NOT_FOUND.value,
        )

    # === 1-1. 버전 개수 확인 ===
    total_versions = db.query(ModelVersion).filter(ModelVersion.model_id == model_id).count()
    if total_versions <= 1:
        raise CustomHTTPException(
            status.HTTP_400_BAD_REQUEST, CustomCode.ERR_400.value, Messages.MODEL_VERSION_DELETE_SINGLE_FORBIDDEN.value
        )

    # === 2. 삭제 진행 ===
    try:
        # 모델 전체 READY 상태 확인
        model_ready = triton_client.client.is_model_ready(model_name=model.name)

        if model_ready:
            # 해당 버전 READY 상태 확인
            version_ready = triton_client.client.is_model_ready(model_name=model.name, model_version=str(version))

            if version_ready:
                # 현재 로드 중인 버전 삭제, 삭제 후 모델 다시 로드
                triton_client.unload_model(model.name)
                _delete_version_files_and_db(model, version, db)
                triton_client.load_model(model_name=model.name)
            else:
                # 다른 버전이 로드 중
                _delete_version_files_and_db(model, version, db)
        else:
            # 모델 전체가 언로드 상태
            _delete_version_files_and_db(model, version, db)

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.ERR_503.value,
            message=Messages.TRITON_CONNECTION_ERROR.value,
            data={"detail": str(e)},
        )

    # === 6. 삭제 이력 기록 ===
    save_model_release(
        db,
        actor_id=user.user_id,
        type_=ReleaseType.VERSION,
        action_=ReleaseAction.DELETE,
        target_id=model_id,
        reason=req.description or f"{model.name}의 {version}번 버전 삭제",
    )
    db.commit()

    return create_response(
        CustomCode.MODEL_005.value,
        Messages.MODEL_VERSION_DELETE_SUCCESS.value,
        None,
    )


# =====================================================
# 6. 모델 전체 삭제
# =====================================================
def delete_model_service(model_id: int, req: ModelDeleteRequest, db: Session):
    # === 1. 모델 및 유저 검증 ===
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.MODEL_NOT_FOUND_FOUND.value,
        )

    user = _get_user_or_404(db, req.loginId)

    # === 2. Triton 언로드 ===
    try:
        # 모델이 READY이든 아니든, 삭제 전엔 무조건 언로드 시도
        triton_client.unload_model(model_name=model.name)
    except Exception as e:
        pass  # 삭제 로직이 중단되지 않아야 하므로 무시 가능 (추후 로그 남길 수 있음)

    # === 3. DB 삭제 ===
    try:
        db.delete(model)
        db.commit()

    except Exception as e:
        db.rollback()
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_DELETE_DB_ERROR.value,
            data={"detail": str(e)},
        )

    # === 4. 파일 삭제 ===
    root_dir = MODEL_REPO_ROOT / model.name
    if root_dir.exists():
        shutil.rmtree(root_dir, ignore_errors=True)
    else:
        pass  # 이미 없으면 무시

    # === 5. 삭제 이력 ===
    save_model_release(
        db,
        actor_id=user.user_id,
        type_=ReleaseType.MODEL,
        action_=ReleaseAction.DELETE,
        target_id=model_id,
        reason=req.description or f"{model.name} 모델 전체 삭제",
    )
    db.commit()

    return create_response(CustomCode.MODEL_006.value, Messages.MODEL_DELETE_SUCCESS.value, None)


# =====================================================
# 9. 특정 모델의 버전 목록 및 현재 Config 조회
# =====================================================
def get_model_detail_service(model_id: int, db: Session):
    # 모델 존재 확인
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.MODEL_NOT_FOUND_FOUND.value,
        )

    # 현재 Config 조회
    config = db.query(ModelConfig).filter(ModelConfig.model_id == model_id, ModelConfig.is_current == True).first()

    config_data = None
    if config:
        config_data = {
            "configId": config.config_id,
            "version": config.version,
            "filePath": config.file_path,
            "content": config.content,
            "createdAt": config.created_at.strftime("%y-%m-%d %H:%M:%S"),
        }

    # 모델 타입별 분기
    if model.type == "ENSEMBLE":
        # 앙상블 모델은 버전 리스트 없이 config만 반환
        data = {
            "modelId": model.model_id,
            "modelName": model.name,
            "modelType": model.type,
            "versions": None,  # 또는 []
            "config": config_data,
        }

    else:
        # 일반 모델은 버전 리스트 포함
        versions = (
            db.query(ModelVersion, User)
            .join(User, User.user_id == ModelVersion.created_by, isouter=True)
            .filter(ModelVersion.model_id == model_id)
            .order_by(ModelVersion.version.asc())
            .all()
        )

        version_list = [
            {
                "versionId": mv.model_version_id,
                "version": mv.version,
                "fileName": mv.represent_file_name,
                "userName": user.login_id if user else None,
                "createdAt": mv.created_at.strftime("%y-%m-%d %H:%M:%S"),
            }
            for mv, user in versions
        ]

        data = {
            "modelId": model.model_id,
            "modelName": model.name,
            "modelType": model.type,
            "versions": version_list,
            "config": config_data,
        }

    return create_response(
        CustomCode.MODEL_009.value,
        Messages.MODEL_LIST_FETCH_SUCCESS.value,
        data,
    )
