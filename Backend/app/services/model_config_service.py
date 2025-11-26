import time
from fastapi import status
from sqlalchemy import func
from sqlalchemy.orm import Session
from pathlib import Path

from app.clients.triton_client import triton_client
from app.core.customException import CustomHTTPException
from app.models.model import Model, ReleaseAction, ReleaseType
from app.services.model_service import save_model_config, save_model_release
from app.services.server_service import get_user_or_404
from app.core.response_utils import create_response
from app.models.model_config import ModelConfig
from app.models.user import User
from app.common.codes import CustomCode
from app.common.messages import Messages


async def get_config_history_with_selected_service(db: Session, model_id: int):
    """특정 모델의 전체 Config 상세 내용 + 이력 조회"""

    results = (
        db.query(ModelConfig, User)
        .join(User, User.user_id == ModelConfig.created_by, isouter=True)
        .filter(ModelConfig.model_id == model_id)
        .order_by(ModelConfig.version.asc())
        .all()
    )

    if not results:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.MODEL_NOT_FOUND.value,
        )

    history = [
        {
            "configId": cfg.config_id,
            "version": cfg.version,
            "createdAt": cfg.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "userName": user.name if user else None,
            "isCurrent": cfg.is_current,
            "content": cfg.content,
        }
        for cfg, user in results
    ]

    data = {"modelId": model_id, "configs": history}

    return create_response(
        code=CustomCode.CONFIG_001.value,
        message=Messages.CONFIG_HISTORY_WITH_FETCH_SUCCESS.value,
        data=data,
    )


def update_model_config_service(
    model_id: int,
    login_id: str,
    config_content: str,
    description: str,
    db: Session,
):
    """모델 Config 수정 + Triton 반영 + 실패 시 완전 롤백"""

    # 1. 유효성 검증
    user = get_user_or_404(db, login_id)

    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.MODEL_NOT_FOUND.value,
        )

    cfg_path = Path(model.storage_dir) / "config.pbtxt"
    if not cfg_path.exists():
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            Messages.CONFIG_NOT_FOUND.value,
        )

    # 2. 기존 config (DB 기준) 가져오기 → 파일 롤백용
    previous_config = (
        db.query(ModelConfig).filter(ModelConfig.model_id == model_id, ModelConfig.is_current == True).first()
    )

    if not previous_config:
        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR, CustomCode.ERR_500.value, Messages.CONFIG_DELETE_NOT_FOUND.value
        )

    previous_content = previous_config.content

    # STEP 1: 파일 수정 + Triton reload
    try:
        # 파일에 새 config 쓰기
        cfg_path.write_text(config_content, encoding="utf-8")
        time.sleep(0.2)

        # Triton 모델 reload (여기서 오류 발생 가능)
        triton_client.unload_model(model.name)
        triton_client.load_model(model.name)

    except Exception as e:
        # 파일 롤백 (이전 정상 config 복구)
        cfg_path.write_text(previous_content, encoding="utf-8")

        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.MODEL_LOAD_ERROR.value,
            {"error": str(e)},
        )

    # STEP 2: DB 업데이트 (여기서 실패하면 파일 롤백 + DB rollback)
    try:
        # 기존 최신 버전 inactive
        db.query(ModelConfig).filter(ModelConfig.model_id == model_id, ModelConfig.is_current == True).update(
            {"is_current": False}, synchronize_session=False
        )

        latest_version = db.query(func.max(ModelConfig.version)).filter(ModelConfig.model_id == model_id).scalar() or 0

        # 새 버전 저장
        new_config = save_model_config(
            db=db,
            model_id=model_id,
            version=latest_version + 1,
            content=config_content,
            file_path=str(cfg_path),
            user_id=user.user_id,
        )

        # 릴리즈 로그 기록
        save_model_release(
            db=db,
            actor_id=user.user_id,
            type_=ReleaseType.CONFIG,
            action_=ReleaseAction.UPDATE,
            target_id=model_id,
            reason=description or "Config 수정 및 재적용",
        )

        # 오래된 버전 자동 삭제
        old_configs = (
            db.query(ModelConfig)
            .filter(ModelConfig.model_id == model_id)
            .order_by(ModelConfig.created_at.desc())
            .offset(5)
            .all()
        )
        for old in old_configs:
            db.delete(old)

        db.commit()

    except Exception as e:
        # DB 오류 발생 → 파일 rollback + DB rollback
        db.rollback()
        cfg_path.write_text(previous_content, encoding="utf-8")

        raise CustomHTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            CustomCode.ERR_500.value,
            Messages.CONFIG_DB_UPDATE_ERROR.value,
            {"error": str(e)},
        )

    # SUCCESS RESPONSE
    return create_response(
        code=CustomCode.CONFIG_002.value,
        message=Messages.CONFIG_UPDATE_SUCCESS.value,
        data={
            "configId": new_config.config_id,
            "version": new_config.version,
            "filePath": str(cfg_path),
            "createdBy": user.name,
            "createdAt": new_config.created_at,
            "isCurrent": True,
        },
    )


async def delete_selected_config_service(
    db: Session,
    model_id: int,
    config_id: int,
    login_id: str,
    description: str,
):
    """특정 모델의 선택된 Config를 삭제"""
    user = get_user_or_404(db, login_id)

    # (1) 모델 존재 여부 확인
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.MODEL_NOT_FOUND.value,
        )

    # (2) Config 존재 여부 확인
    config = db.query(ModelConfig).filter(ModelConfig.model_id == model_id, ModelConfig.config_id == config_id).first()

    if not config:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.CONFIG_NOT_FOUND.value,
        )

    # (3) 현재 config 삭제 불가
    if config.is_current:
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,
            message=Messages.CONFIG_CURRENT_CANNOT_DELETE.value,
        )

    #  (4) 삭제 + 릴리즈 기록
    try:
        db.delete(config)

        save_model_release(
            db=db,
            actor_id=user.user_id,
            type_=ReleaseType.CONFIG,
            action_=ReleaseAction.DELETE,
            target_id=model_id,
            reason=description or f"Config {config_id} deleted",
        )

        db.commit()

    except Exception as e:
        db.rollback()
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.CONFIG_DB_DELETE_ERROR.value,
        )

    return create_response(
        code=CustomCode.CONFIG_003.value,
        message=Messages.CONFIG_DELETE_SUCCESS.value,
        data=None,
    )
