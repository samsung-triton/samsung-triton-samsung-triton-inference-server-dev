from typing import List
from pydantic import BaseModel


class ValueItem(BaseModel):
    ts: str
    value: float


class SeriesItem(BaseModel):
    gpu_uuid: str
    values: List[ValueItem]


class NoneGPUSeriesItem(BaseModel):
    values: List[ValueItem]


class TimeWindow(BaseModel):
    start: str
    end: str
    step: str


class MetricData(BaseModel):
    window: TimeWindow
    vram: List[SeriesItem]
    ram: List[SeriesItem]
