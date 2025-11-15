import asyncio
import httpx
import math
from fastapi import status
from datetime import datetime, timedelta
from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.config import settings, TIMEZONE
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.core.standard_time_manager import current_standard_time
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.schemas.timeseries_schema import ValueItem, SeriesItem, TimeWindow, MetricData, NoneGPUSeriesItem
from app.schemas.base_schema import BaseResponse
from app.models.model import Model
from app.models.inference_logs import InferenceLogs
from app.clients.triton_client import triton_client
from app.services.server_service import get_server_status_service


# ============================================================
# 1. 서버 실시간 메트릭
# ============================================================
async def get_server_metrics_service():
    try:
        queries = {
            "cpu_util": "avg(nv_cpu_utilization)",
            "gpu_util": "avg(nv_gpu_utilization) by (gpu_uuid, device)",
        }

        results = await asyncio.gather(*[prom_query(q) for q in queries.values()])
        data_map = dict(zip(queries.keys(), results))

        def gpu_key(m):
            return (m.get("metric", {}).get("gpu_uuid", ""), m.get("metric", {}).get("device", ""))

        gpu_metrics = {}
        for key in ["gpu_util"]:
            for it in data_map.get(key, []):
                uuid, dev = gpu_key(it)
                val = it.get("value")
                if not val or len(val) < 2:
                    continue
                gpu_metrics.setdefault((uuid, dev), {})[key] = float(val[1])

        gpu_data = []
        for (uuid, dev), vals in gpu_metrics.items():
            gpu_data.append(
                {
                    "uuid": uuid,
                    "gpu_util": round(vals.get("gpu_util", 0), 2),
                }
            )

        cpu_util = 0
        if data_map.get("cpu_util"):
            val = data_map["cpu_util"][0].get("value")
            if val and len(val) >= 2:
                cpu_util = float(val[1])

        data = {
            "timestamp": datetime.now(TIMEZONE).isoformat(),
            "cpu_utilization": round(cpu_util, 2),
            "gpu": gpu_data,
        }

        return create_response(
            code=CustomCode.DASH_001.value,
            message=Messages.SERVER_METRICS_FETCH_SUCCESS.value,
            data=data,
        )

    except CustomHTTPException:
        raise
    except Exception:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.SERVER_METRIC_FAIL.value,
            data=None,
        )


async def prom_query(promql: str):
    ep = f"{settings.PROM_URL.rstrip('/')}/api/v1/query"
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(ep, params={"query": promql})
            r.raise_for_status()
            data = r.json()

            if data.get("status") != "success":
                raise CustomHTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    code=CustomCode.ERR_500.value,
                    message=Messages.PROMETHEUS_BAD_STATUS.value,
                    data=None,
                )

            return data["data"]["result"]

    except CustomHTTPException:
        raise
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"{Messages.PROMETHEUS_QUERY_FAIL.value}: {e}",
            data=None,
        )


async def prom_query_range(promql: str, start: datetime, end: datetime, step: str = "600"):
    ep = f"{settings.PROM_URL.rstrip('/')}/api/v1/query_range"

    def to_epoch(dt: datetime) -> float:
        return dt.timestamp()

    params = {
        "query": promql,
        "start": to_epoch(start),
        "end": to_epoch(end),
        "step": step,  # "600"
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(ep, params=params)
        r.raise_for_status()
        data = r.json()

        return data["data"]["result"]


# ============================================================
# 2. GPU 메모리 / CPU 메모리 시계열
# ============================================================
async def get_timeseries_service(end_iso: Optional[str] = None) -> create_response:
    """
    GPU 메모리 사용률(%) 시계열
    - 구간: [end-1h, end]
    - 간격: 10분
    - PromQL: 100 * used / total (gpu_uuid, device로 정렬)
    """
    try:
        # 1) end 시각 파싱
        if end_iso:
            if end_iso.isdigit():
                end_dt = datetime.fromtimestamp(int(end_iso), tz=TIMEZONE)
            else:
                end_dt = datetime.fromisoformat(end_iso.replace("Z", "+00:00"))
                if end_dt.tzinfo is None:
                    end_dt = end_dt.replace(tzinfo=TIMEZONE)
        else:
            end_dt = datetime.now(TIMEZONE)

        start_dt = end_dt - timedelta(hours=1)

        vram_promql = (
            "100 * (sum(nv_gpu_memory_used_bytes) by (gpu_uuid, device)) "
            "/ (sum(nv_gpu_memory_total_bytes) by (gpu_uuid, device))"
        )
        ram_promql = (
            "100 * (sum(nv_cpu_memory_used_bytes) by (gpu_uuid, device)) "
            "/ (sum(nv_cpu_memory_total_bytes) by (gpu_uuid, device))"
        )

        vram_result: List[dict] = await prom_query_range(promql=vram_promql, start=start_dt, end=end_dt, step="10m")
        ram_result: List[dict] = await prom_query_range(promql=ram_promql, start=start_dt, end=end_dt, step="10m")

        # 3) 결과 변환 (NaN/Inf 방어)
        vram_series_list: List[SeriesItem] = []
        for s in vram_result:
            metric = s.get("metric", {})

            points: List[ValueItem] = []
            for ts, val in s.get("values", []):
                try:
                    ts_dt = datetime.fromtimestamp(float(ts), tz=TIMEZONE)
                    v = float(val)
                    if math.isnan(v) or math.isinf(v):
                        continue
                    points.append(ValueItem(ts=ts_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), value=round(v, 2)))
                except Exception:
                    continue

            vram_series_list.append(SeriesItem(gpu_uuid=metric.get("gpu_uuid", "unknown"), values=points))

        ram_series_list: List[SeriesItem] = []
        for s in ram_result:
            metric = s.get("metric", {})

            points: List[ValueItem] = []
            for ts, val in s.get("values", []):
                try:
                    ts_dt = datetime.fromtimestamp(float(ts), tz=TIMEZONE)
                    v = float(val)
                    if math.isnan(v) or math.isinf(v):
                        continue
                    points.append(ValueItem(ts=ts_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), value=round(v, 2)))
                except Exception:
                    continue

            ram_series_list.append(NoneGPUSeriesItem(values=points))

        # 4) TimeWindow 생성
        time_window = TimeWindow(
            start=start_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), end=end_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), step="10m"
        )

        data = MetricData(window=time_window, vram=vram_series_list, ram=ram_series_list)

        return create_response(
            code=CustomCode.DASH_002.value, message=Messages.RESOURCE_TIMESERIES_FETCH_SUCCESS.value, data=data.dict()
        )

    except CustomHTTPException:
        raise
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"{Messages.SERVER_METRIC_FAIL.value}: {e}",
            data=None,
        )


# ============================================================
# 3. model_id 기반 모델 통계
# ============================================================
def get_aggregation_window_from_str(base_time_str: str) -> tuple[datetime, datetime]:
    now = datetime.now(TIMEZONE)
    hh, mm = map(int, base_time_str.split(":"))
    today_base = now.replace(hour=hh, minute=mm, second=0, microsecond=0)
    if now >= today_base:
        return today_base, now
    else:
        return today_base - timedelta(days=1), today_base


def get_model_per_inference_stats_service(model_id: int, db: Session) -> BaseResponse:
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(status.HTTP_404_NOT_FOUND, CustomCode.ERR_404.value, Messages.MODEL_NOT_FOUND.value)

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
        message=f"{model.name} 통계 조회 성공",
        data={
            "model_name": model.name,
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


# ============================================================
# 4. model_id 기반 모델 latency
# ============================================================
async def get_model_per_inference_latency_service(
    model_id: int, end_iso: Optional[str], db: Session
) -> create_response:
    model = db.query(Model).filter(Model.model_id == model_id).first()
    if not model:
        raise CustomHTTPException(status.HTTP_404_NOT_FOUND, CustomCode.ERR_404.value, Messages.MODEL_NOT_FOUND.value)

    model_name = model.name

    try:
        # 1) end 시각 파싱
        if end_iso:
            if end_iso.isdigit():
                end_dt = datetime.fromtimestamp(int(end_iso), tz=TIMEZONE)
            else:
                end_dt = datetime.fromisoformat(end_iso.replace("Z", "+00:00"))
                if end_dt.tzinfo is None:
                    end_dt = end_dt.replace(tzinfo=TIMEZONE)
        else:
            end_dt = datetime.now(TIMEZONE)

        start_dt = end_dt - timedelta(hours=1)

        def to_epoch(dt: datetime) -> float:
            return dt.timestamp()

        # 2) PromQL 준비
        metric_keys = {
            "total": "nv_inference_request_duration_us",
            "queue": "nv_inference_queue_duration_us",
            "input": "nv_inference_compute_input_duration_us",
            "infer": "nv_inference_compute_infer_duration_us",
            "output": "nv_inference_compute_output_duration_us",
        }

        def build_query(metric_key: str) -> str:
            return f'increase({metric_key}{{model="{model_name}"}}[10m])'

        latency_results = {}

        # 3) prom_query_range 호출 (async 정상)
        for key, metric_key in metric_keys.items():
            promql = build_query(metric_key)

            result = await prom_query_range(promql=promql, start=start_dt, end=end_dt, step="600")  # 600초 (10분)

            latency_results[key] = result

        # 4) 데이터 변환
        def convert_prometheus_series(result: List[dict]):
            none_gpu_series_list = []

            for s in result:
                raw_values = s.get("values")
                if raw_values is None:
                    v = s.get("value")
                    raw_values = [v] if v else []

                points = []
                for ts, val in raw_values:
                    try:
                        ts_dt = datetime.fromtimestamp(float(ts), tz=TIMEZONE)
                        v = float(val)
                        v_ms = round(v / 1000, 2)
                        points.append(ValueItem(ts=ts_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), value=v_ms))
                    except:  # noqa: E722
                        continue

                none_gpu_series_list.append(NoneGPUSeriesItem(values=points))

            return none_gpu_series_list

        total_series = convert_prometheus_series(latency_results["total"])
        queue_series = convert_prometheus_series(latency_results["queue"])
        input_series = convert_prometheus_series(latency_results["input"])
        infer_series = convert_prometheus_series(latency_results["infer"])
        output_series = convert_prometheus_series(latency_results["output"])

        time_window = TimeWindow(
            start=start_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), end=end_dt.strftime("%Y-%m-%dT%H:%M:%SZ"), step="10m"
        )

        data = {
            "window": time_window.dict(),
            "latency": {
                "total": [s.dict() for s in total_series],
                "queue": [s.dict() for s in queue_series],
                "input": [s.dict() for s in input_series],
                "infer": [s.dict() for s in infer_series],
                "output": [s.dict() for s in output_series],
            },
        }

        return create_response(code=CustomCode.DASH_003.value, message="{model.name} 레이턴시 조회 성공", data=data)

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"Failed: {e}",
            data=None,
        )


# ============================================================
# 5. 대시보드 모델 목록 조회
# ============================================================ㅋ
async def get_dashboard_models_list_service(db: Session):
    # 1. 서버 상태 확인
    try:
        triton_alive = triton_client.is_server_ready()
    except Exception:
        triton_alive = False

    if not triton_alive:
        return create_response(
            code=CustomCode.DASH_005.value,
            message=Messages.DASHBOARD_MODEL_LIST_SUCCESS.value,
            data={"models": []},
        )

    # 2. Triton 모델 READY 리스트 가져오기
    try:
        resp = triton_client.list_models()
        triton_models = resp.get("models", [])

        ready_names = {m["name"] for m in triton_models if m.get("state") == "READY"}

        if not ready_names:
            return create_response(
                CustomCode.DASH_005.value,
                Messages.DASHBOARD_MODEL_LIST_SUCCESS.value,
                {"models": []},
            )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.MODEL_LIST_FETCH_ERROR.value,
            data={"detail": str(e)},
        )

    # 3. DB 모델 매핑
    db_models = db.query(Model).filter(Model.name.in_(ready_names)).all()

    results = []

    base_time_str = current_standard_time()
    start_time, end_time = get_aggregation_window_from_str(base_time_str)

    for m in db_models:
        q = (
            db.query(
                func.count(InferenceLogs.inference_log_id).label("inference_total"),
                func.count().filter(InferenceLogs.inference_status == "OK").label("inference_ok"),
                func.count().filter(InferenceLogs.inference_status == "NG").label("inference_ng"),
            )
            .filter(InferenceLogs.model_id == m.model_id)
            .filter(InferenceLogs.completed_at >= start_time)
            .filter(InferenceLogs.completed_at < end_time)
        )

        row = q.first()

        inference_total = row.inference_total or 0
        inference_ok = row.inference_ok or 0
        ok_ratio = round(inference_ok / inference_total, 3) if inference_total > 0 else 0.0

        results.append(
            {
                "modelId": m.model_id,
                "modelName": m.name,
                "inference_total": inference_total,
                "inference_ok": inference_ok,
                "ok_ratio": ok_ratio,
            }
        )

    return create_response(
        code=CustomCode.DASH_005.value,
        message=Messages.DASHBOARD_MODEL_LIST_SUCCESS.value,
        data={"models": results},
    )
