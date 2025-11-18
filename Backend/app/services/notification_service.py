from sqlalchemy.orm import Session

from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response


def get_inference_notification_service(db: Session) -> BaseResponse:

    return create_response(
        # CustomCode.NOTI_001.value,
        # "notification을 정상 응답",
        # data = {
        #     "type" : ,
        #     "message" : ,
        #     "time" :
        # },
    )
