from fastapi import status
from sqlalchemy.orm import Session

from app.models.masterkey import MasterKey
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages


def varify_mastekey_service(masterKey: int, db: Session) -> BaseResponse:
    mk = db.query(MasterKey).filter(MasterKey.key == masterKey).first()
    if not mk:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_401.value,
            message=Messages.MASTER_KEY_MISMATCH.value,
            data=None,
        )

    return create_response(CustomCode.MASTER_001.value, Messages.MASTER_KEY_MATCH.value)
