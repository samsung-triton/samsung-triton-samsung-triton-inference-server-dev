from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.exceptions import raise_http_exception
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status


def login_user_service(login_id: str, password: str, db: Session) -> BaseResponse:
    if not login_id or not password:
        return raise_http_exception(status.HTTP_400_BAD_REQUEST, CustomCode.ERR_400.value, Messages.INVALID_PARAM.value)

    user = db.query(User).filter(User.login_id == login_id).first()
    if not user:
        return raise_http_exception(status.HTTP_404_NOT_FOUND, CustomCode.ERR_404.value, Messages.USER_NOT_FOUND.value)

    if user.password != password:
        return raise_http_exception(
            status.HTTP_401_UNAUTHORIZED, CustomCode.ERR_401.value, Messages.INVALID_CREDENTIAL.value
        )

    return create_response(
        CustomCode.AUTH_001.value, Messages.LOGIN_SUCCESS.value, {"user_id": user.user_id, "role": user.role}
    )
