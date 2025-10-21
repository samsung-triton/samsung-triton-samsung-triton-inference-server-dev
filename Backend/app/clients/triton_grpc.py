# app/clients/triton_grpc.py
from typing import List, Optional, Dict, Any
from dataclasses import dataclass
import numpy as np
from dotenv import load_dotenv
import os
from tritonclient.grpc import InferenceServerClient, InferInput, InferRequestedOutput

# .env 로드
load_dotenv()
# .env에서 읽기 (없으면 기본값)
DEFAULT_GRPC_URL = os.getenv("TRITON_GRPC_URL", "localhost:8001")

# Triton 결과를 dict(list)로 바로 쓰기 쉽게 담아주는 컨테이너
@dataclass
class TritonResult:
    outputs: Dict[str, Any]

# NumPy dtype 매핑 (필요한 최소만)
_DTYPE = {
    "FP32": np.float32, "FP16": np.float16,
    "INT64": np.int64,  "INT32": np.int32, "INT16": np.int16, "INT8": np.int8,
    "UINT64": np.uint64, "UINT32": np.uint32, "UINT16": np.uint16, "UINT8": np.uint8,
    "BOOL": np.bool_
}

def _to_numpy(data, datatype: str, shape: List[int]) -> np.ndarray:
    if datatype == "BYTES":
        arr = np.array(data, dtype=object)      # 문자열/바이너리
    else:
        arr = np.array(data, dtype=_DTYPE.get(datatype, np.float32))
    return arr.reshape(shape)

class TritonGrpc:
    """Triton gRPC 얇은 래퍼 (동기 전용)."""
    def __init__(self, url: str = DEFAULT_GRPC_URL, verbose: bool = False):
        self.url = url or DEFAULT_GRPC_URL
        if not isinstance(self.url, str) or not self.url.strip():
            raise ValueError("TRITON_GRPC_URL is empty. Check your .env or pass url=...")
        self.client = InferenceServerClient(url=self.url, verbose=verbose)

    # ---------- Health / Meta ----------
    def is_server_live(self) -> bool:
        return self.client.is_server_live()

    def is_server_ready(self) -> bool:
        return self.client.is_server_ready()

    def is_model_ready(self, name: str, version: str = "") -> bool:
        return self.client.is_model_ready(name, version)

    def get_server_metadata(self):
        return self.client.get_server_metadata()

    def get_model_metadata(self, name: str, version: str = ""):
        return self.client.get_model_metadata(name, version)

    def get_model_config(self, name: str, as_json: bool = True):
        return self.client.get_model_config(name, as_json=as_json)

    # ---------- Repository ----------
    def get_model_repository_index(self):
        return self.client.get_model_repository_index()

    def load_model(self, name: str):
        return self.client.load_model(name)

    def unload_model(self, name: str):
        return self.client.unload_model(name)

    # ---------- Stats ----------
    def get_inference_statistics(self, model_name: Optional[str] = None):
        return self.client.get_inference_statistics(model_name) if model_name else self.client.get_inference_statistics()

    # ---------- Inference ----------
    def infer(
        self,
        model_name: str,
        inputs: List[Dict[str, Any]],
        outputs: Optional[List[str]] = None,
        model_version: str = "",
        client_timeout: Optional[float] = None,
    ) -> TritonResult:
        infer_inputs = []
        for it in inputs:
            ii = InferInput(it["name"], it["shape"], it["datatype"])
            ii.set_data_from_numpy(_to_numpy(it["data"], it["datatype"], it["shape"]))
            infer_inputs.append(ii)

        infer_outputs = (
            [InferRequestedOutput(name) for name in outputs]
            if outputs else None
        )
        
        res = self.client.infer(
            model_name=model_name,
            inputs=infer_inputs,
            outputs=infer_outputs,
            model_version=model_version,
            client_timeout=client_timeout,
        )
        out = {}
        for meta in res.get_response().outputs:
            out[meta.name] = res.as_numpy(meta.name).tolist()
        return TritonResult(outputs=out)
