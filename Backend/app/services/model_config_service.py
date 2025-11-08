from sqlalchemy.orm import Session
from app.models.model_config import ModelConfig
from app.models.user import User
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status
from app.core.response_utils import create_response

async def get_current_config_service(db: Session, model_id: int):
    # 특정 모델의 현재 사용 중인 Config 조회
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

    return create_response(
        code="CONFIG-001",
        message="현재 사용 중인 Config가 조회되었습니다.",
        data=data,
    )
