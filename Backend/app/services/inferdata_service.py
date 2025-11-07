from sqlalchemy.orm import Session
from app.models.inference_logs import InferenceLogs
from app.models.model import Models
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status, UploadFile
from pathlib import Path
from app.core.config import settings
from datetime import datetime
import random
import shutil
import logging


def generate_custom_uid() -> str:
    now = datetime.now()
    date_part = now.strftime("%Y%m%d")
    time_part = now.strftime("%H%M%S")
    rand_part = f"{random.randint(0, 99999):05d}"
    return f"{date_part}_{time_part}_{rand_part}"


logger = logging.getLogger(__name__)


def save_input_before_infer_service(clientId: str, modelName: str, dataFile: UploadFile, db: Session) -> BaseResponse:
    model = db.query(Models).filter(Models.name == modelName).first()

    if not model:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.MODEL_NOT_FOUND.value,
            data=None,
        )

    try:
        save_dir = Path(settings.INFER_DATA_SAVE_PATH) / "Input"
        save_dir.mkdir(parents=True, exist_ok=True)

        uid = generate_custom_uid()
        file_path = save_dir / f"{uid}_{dataFile.filename}"

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(dataFile.file, buffer)

        new_log = InferenceLogs(
            uid=uid,
            client_id=clientId,
            input_path=str(file_path),
            model_id=model.model_id,
        )
        db.add(new_log)
        db.commit()
        db.refresh(new_log)

        return create_response(
            CustomCode.UPLOAD_001,
            Messages.INPUT_DATA_SAVE_SUCCESS.value,
            {"uid": uid, "input_path": str(file_path)},
        )

    except Exception as e:
        logger.error(f"데이터 저장 중 오류 발생: {e}")  # ✅ 로그 출력 추가
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.INPUT_DATA_SAVE_FAIL.value,
            data=None,
        )
