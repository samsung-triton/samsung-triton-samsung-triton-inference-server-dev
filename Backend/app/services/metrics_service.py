import asyncio
import httpx
import math
from fastapi import status
from datetime import datetime, timedelta
from typing import List, Optional

from app.core.config import settings
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.schemas.timeseries_schema import ValueItem, SeriesItem, TimeWindow, MetricData, NoneGPUSeriesItem
from app.core.config import TIMEZONE


async def get_server_metrics_service():
    """서버 실시간 메트릭 조회"""
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
