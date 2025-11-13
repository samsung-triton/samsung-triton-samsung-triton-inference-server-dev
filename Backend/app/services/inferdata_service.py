from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.inference_logs import InferenceLogs
from app.models.model import Model
from app.schemas.base_schema import BaseResponse
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.core.standard_time_manager import current_standard_time
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from fastapi import status, UploadFile
from pathlib import Path
from app.core.config import settings
from datetime import datetime, timedelta
from app.core.config import TIMEZONE
import random
import shutil
import logging


def generate_custom_uid() -> str:
    now = datetime.now(TIMEZONE)
    date_part = now.strftime("%Y%m%d")
    time_part = now.strftime("%H%M%S")
    rand_part = f"{random.randint(0, 99999):05d}"
    return f"{date_part}_{time_part}_{rand_part}"


logger = logging.getLogger(__name__)


def save_input_before_infer_service(
    clientId: str, modelName: str, dataFiles: List[UploadFile], db: Session
) -> BaseResponse:
    model = db.query(Model).filter(Model.name == modelName).first()

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
        for file in dataFiles:
            file_path = save_dir / f"{uid}_{file.filename}"
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            saved_paths.append(str(file_path))

        # 로그
        new_log = InferenceLogs(
            uid=uid,
            client_id=clientId,
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
            code=CustomCode.INFERENCE_002,
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


def get_aggregation_window_from_str(base_time_str: str) -> tuple[datetime, datetime]:
    now = datetime.now(TIMEZONE)
    hh, mm = map(int, base_time_str.split(":"))
    today_base = now.replace(hour=hh, minute=mm, second=0, microsecond=0)
    if now >= today_base:
        return today_base, now
    else:
        return today_base - timedelta(days=1), today_base


def get_model_per_inference_stats_service(model_name: str, db: Session) -> BaseResponse:
    model = db.query(Model).filter(Model.name == model_name).first()
    if not model:
        raise CustomHTTPException(
            status.HTTP_404_NOT_FOUND,
            CustomCode.ERR_404.value,
            f"모델 '{model_name}'을(를) 찾을 수 없습니다.",
        )

    base_time_str = current_standard_time()  # "HH:MM"
    start_time, end_time = get_aggregation_window_from_str(base_time_str)

    q = (
        db.query(
            func.count(InferenceLogs.inference_log_id).label("request_total"),
            func.count().filter(InferenceLogs.inference_status == "OK").label("inference_ok"),
            func.count().filter(InferenceLogs.inference_status == "NG").label("inference_ng"),
            func.count().filter(InferenceLogs.inference_status == "ERROR").label("inference_error"),
            func.count().filter(InferenceLogs.request_status == "SUCCESS").label("request_success"),
            func.count().filter(InferenceLogs.request_status == "FAIL").label("request_fail"),
            func.avg(InferenceLogs.duration_ms).label("avg_latency"),
        )
        .filter(InferenceLogs.model_id == model.model_id)
        .filter(InferenceLogs.completed_at >= start_time)
        .filter(InferenceLogs.completed_at < end_time)
    )

    inferenceData = q.first()

    request_total = inferenceData.request_total or 0
    request_success = inferenceData.request_success or 0
    request_fail = inferenceData.request_fail or 0
    inference_total = inferenceData.request_success or 0
    inference_ok = inferenceData.inference_ok or 0
    inference_ng = inferenceData.inference_ng or 0
    inference_error = inferenceData.inference_error or 0
    avg_ms = round(inferenceData.avg_latency or 0, 2)

    return create_response(
        code=CustomCode.DASH_003.value,
        message=f"{model_name} 통계 조회 성공",
        data={
            "model_name": model_name,
            "base_time": base_time_str,  # "HH:MM"
            "aggregation_start": start_time.isoformat(),
            "aggregation_end": end_time.isoformat(),
            "request_total": request_total,
            "request_success": request_success,
            "request_fail": request_fail,
            "inference_total": inference_total,
            "inference_ok": inference_ok,
            "inference_ng": inference_ng,
            "inference_error": inference_error,
            "ok_ratio": round(inference_ok / inference_total, 3) if inference_total > 0 else 0.0,
            "avg_latency_ms": avg_ms,
        },
    )
