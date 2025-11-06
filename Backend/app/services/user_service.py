from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status


def login_user_service(login_id: str, password: str, db: Session) -> BaseResponse:

    user = db.query(User).filter(User.login_id == login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
            data=None,
        )

    if user.password != password:
        raise CustomHTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code=CustomCode.ERR_401.value,
            message=Messages.INVALID_CREDENTIAL.value,
            data=None,
        )

    return create_response(CustomCode.AUTH_001.value, Messages.LOGIN_SUCCESS.value, {"role": user.role})
