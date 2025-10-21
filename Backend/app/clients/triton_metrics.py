# app/clients/triton_metrics.py
from __future__ import annotations
import re
from typing import Dict, Tuple, Optional
from dotenv import load_dotenv
import os
import requests

# .env 로드
load_dotenv()
# .env에서 읽기 (없으면 기본값)
DEFAULT_METRICS_URL = os.getenv("TRITON_METRICS_URL", "http://localhost:8002/metrics")

def get_metrics_text(url: Optional[str] = None, timeout: float = 3.0) -> str:
    """
    Triton Prometheus 원문 텍스트 가져오기.
    - url 인자가 없으면 .env의 TRITON_METRICS_URL 사용
    """
    metrics_url = url or DEFAULT_METRICS_URL
    resp = requests.get(metrics_url, timeout=timeout)
    resp.raise_for_status()
    return resp.text

def parse_counter_and_sum(text: str, metric_base: str) -> Tuple[float, float]:
    """
    histogram 계열의 _sum/_count 추출 (라벨 없는 전체 합계 기준)
    예: nv_inference_request_duration_us_sum / _count
    """
    sum_pat = re.compile(rf"^{re.escape(metric_base)}_sum\s+([0-9eE\.\+\-]+)\s*$", re.M)
    cnt_pat = re.compile(rf"^{re.escape(metric_base)}_count\s+([0-9eE\.\+\-]+)\s*$", re.M)
    msum = sum_pat.search(text)
    mcnt = cnt_pat.search(text)
    s = float(msum.group(1)) if msum else 0.0
    c = float(mcnt.group(1)) if mcnt else 0.0
    return s, c

def summarize_latency_ms(text: str) -> Dict[str, float]:
    """
    대표 지연 지표 평균(ms) 계산
    - nv_inference_request_duration_us
    - nv_inference_compute_infer_duration_us
    - nv_inference_queue_duration_us
    """
    def avg_ms(base: str) -> float:
        s, c = parse_counter_and_sum(text, base)
        return (s / c / 1000.0) if c > 0 else 0.0

    return {
        "avg_request_ms": avg_ms("nv_inference_request_duration_us"),
        "avg_infer_ms":   avg_ms("nv_inference_compute_infer_duration_us"),
        "avg_queue_ms":   avg_ms("nv_inference_queue_duration_us"),
    }

def scrape_gauge(text: str, name: str) -> Optional[float]:
    """라벨 없는 단순 gauge 한 줄 스크랩 (환경에 따라 다름)"""
    pat = re.compile(rf"^{re.escape(name)}\s+([0-9eE\.\+\-]+)\s*$", re.M)
    m = pat.search(text)
    return float(m.group(1)) if m else None
