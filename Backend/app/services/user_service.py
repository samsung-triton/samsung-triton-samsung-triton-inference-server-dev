from sqlalchemy.orm import Session
from fastapi import status

from app.schemas.base_schema import BaseResponse
from app.core.customException import CustomHTTPException
from app.core.response_utils import create_response
from app.common.utils import get_user_or_404
from app.common.codes import CustomCode
from app.common.messages import Messages


def login_user_service(login_id: str, password: str, db: Session) -> BaseResponse:
    user = get_user_or_404(db, login_id)
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
