from sqlalchemy.orm import Session
from app.models.model_config import ModelConfig
from app.models.user import User
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status
from app.core.response_utils import create_response

async def get_current_config_service(db: Session, model_id: int):
    '''특정 모델의 현재 사용 중인 Config 조회'''
    config = (
        db.query(ModelConfig)
        .filter(ModelConfig.model_id == model_id, ModelConfig.is_current == True)
        .first()
    )

    if not config:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=f"모델 ID {model_id}의 현재 Config가 없습니다.",
        )


    data = {
        "configId": config.config_id,
        "version": config.version,
        "content": config.content,
        "createdBy": config.created_by, 
        "createdAt": config.created_at,
    }

    return create_response(CustomCode.CONFIG_001.value,Messages.CONFIG_CURRENT_FETCH_SUCCESS.value,data=data)

async def get_rollback_config_list_service(db: Session, model_id: int):
    """현재 사용 중인 config를 제외한 롤백 가능한 config 목록 조회"""

    # 현재 사용 중이 아닌 Config만 조회
    results = (
        db.query(ModelConfig, User)
        .join(User, User.user_id == ModelConfig.created_by, isouter=True)
        .filter(ModelConfig.model_id == model_id, ModelConfig.is_current == False)
        .order_by(ModelConfig.version.asc())
        .all()
    )

    if not results:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=f"모델 ID {model_id}의 롤백 가능한 Config가 없습니다.",
        )

    # 응답 데이터 구성
    history = [
        {
            "configId": config.config_id,
            "version": config.version,
            "createdAt": config.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "userName": user.name if user else None,
        }
        for config, user in results
    ]

    data = {
        "modelId": model_id,
        "history": history,
    }

    return create_response(code=CustomCode.CONFIG_002.value,message=Messages.CONFIG_HISTORY_FETCH_SUCCESS.value,data=data)


async def get_selected_config_service(db: Session, model_id: int, config_id: int):
    """특정 모델의 선택된 Config 내용을 조회"""

    # 해당 모델의 Config 존재 여부 확인
    result = (
        db.query(ModelConfig, User)
        .join(User, User.user_id == ModelConfig.created_by, isouter=True)
        .filter(
            ModelConfig.model_id == model_id,
            ModelConfig.config_id == config_id
        )
        .first()
    )

    if not result:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=f"모델 ID {model_id}의 Config ID {config_id}를 찾을 수 없습니다.",
        )

    config, user = result

    # 응답 데이터 구성
    data = {
        "configId": config.config_id,
        "version": config.version,
        "content": config.content,
        "createdBy": user.name if user else None,
        "createdAt": config.created_at,
    }

    # 응답 반환
    return create_response(
        code=CustomCode.CONFIG_003.value,
        message=Messages.CONFIG_ONE_FETCH_SUCCESS.value,
        data=data,
    )

