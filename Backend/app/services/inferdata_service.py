import random
import shutil
import logging
from fastapi import status, UploadFile
from pathlib import Path
from typing import List
from sqlalchemy.orm import Session
from datetime import datetime

from app.models.inference_logs import InferenceLogs
from app.models.model import Model
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.config import settings
from app.core.config import TIMEZONE


def generate_custom_uid() -> str:
    now = datetime.now(TIMEZONE)
    date_part = now.strftime("%Y%m%d")
    time_part = now.strftime("%H%M%S")
    rand_part = f"{random.randint(0, 99999):05d}"
    return f"{date_part}_{time_part}_{rand_part}"


logger = logging.getLogger(__name__)


def save_input_before_infer_service(
    client_id: str, model_name: str, data_files: List[UploadFile], db: Session
) -> BaseResponse:
    model = db.query(Model).filter(Model.name == model_name).first()

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
        saved_paths = []

        # 여러 파일 저장 (로그는 한 번만 남김)
        for file in data_files:
            file_path = save_dir / f"{uid}_{file.filename}"
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            saved_paths.append(str(file_path))

        # 로그
        new_log = InferenceLogs(
            uid=uid,
            client_id=client_id,
            input_path=",".join(saved_paths),  # 여러 경로를 문자열로 저장 (또는 JSON 필드라면 리스트로)
            model_id=model.model_id,
        )
        db.add(new_log)
        db.commit()
        db.refresh(new_log)

        return create_response(
            CustomCode.INFERENCE_001,
            Messages.INPUT_DATA_SAVE_SUCCESS.value,
            {
                "uid": uid,
                "input_path": saved_paths,  # 리스트 형태 반환
            },
        )

    except Exception as e:
        logger.error(f"데이터 저장 중 오류 발생: {e}")
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.INPUT_DATA_SAVE_FAIL.value,
            data=None,
        )


def save_output_after_infer_service(uid: str, is_ok: bool, result: str, db: Session) -> BaseResponse:
    inferenceData = db.query(InferenceLogs).filter(InferenceLogs.uid == uid).first()

    if not inferenceData:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.UID_NOT_FOUND.value,
            data=None,
        )

    try:
        save_dir = Path(settings.INFER_DATA_SAVE_PATH) / "Output"
        save_dir.mkdir(parents=True, exist_ok=True)

        file_path = save_dir / f"{uid}_output.txt"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(result)

        inferenceData.output_path = str(file_path)
        inferenceData.result_text = result
        inferenceData.completed_at = datetime.now(TIMEZONE)

        if is_ok or not is_ok:
            inferenceData.request_status = "SUCCESS"
            if is_ok:
                inferenceData.inference_status = "OK"
            elif not is_ok:
                inferenceData.inference_status = "NG"

        db.commit()
        db.refresh(inferenceData)

        return create_response(
            CustomCode.INFERENCE_002,
            Messages.OUTPUT_DATA_SAVE_SUCCESS.value,
            {"uid": uid, "output_path": str(file_path)},
        )

    except Exception as e:
        db.rollback()
        logger.error(f"데이터 저장 중 오류 발생: {e}")
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.OUTPUT_DATA_SAVE_FAIL.value,
            data=None,
        )


def save_binary_output_after_infer_service(
    uid: str, is_ok: bool, extension: str, binary_data: bytes, db: Session
) -> BaseResponse:
    inferenceData = db.query(InferenceLogs).filter(InferenceLogs.uid == uid).first()

    if not inferenceData:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.UID_NOT_FOUND.value,
            data=None,
        )

    try:
        save_dir = Path(settings.INFER_DATA_SAVE_PATH) / "Output"
        save_dir.mkdir(parents=True, exist_ok=True)

        filename = f"{uid}_output.{extension}"
        file_path = save_dir / filename

        with open(file_path, "wb") as f:
            f.write(binary_data)

        inferenceData.output_path = str(file_path)
        inferenceData.completed_at = datetime.now(TIMEZONE)

        inferenceData.request_status = "SUCCESS"
        inferenceData.inference_status = "OK" if is_ok else "NG"

        db.commit()
        db.refresh(inferenceData)

        return create_response(
            code=CustomCode.INFERENCE_003,
            message=Messages.OUTPUT_DATA_SAVE_SUCCESS.value,
            data={"uid": uid, "output_path": str(file_path)},
        )

    except Exception as e:
        db.rollback()
        logger.error(f"바이너리 데이터 저장 중 오류 발생: {e}")

        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.OUTPUT_DATA_SAVE_FAIL.value,
            data=None,
        )
