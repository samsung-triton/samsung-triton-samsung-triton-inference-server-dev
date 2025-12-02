import tritonclient.grpc as grpcclient
from typing import List, Dict

from app.core.config import settings


class TritonClient:
    """Triton GRPC 클라이언트 래퍼"""

    def __init__(self, url: str = None, verbose: bool = False):
        self.client = grpcclient.InferenceServerClient(url=url or settings.TRITON_GRPC_URL, verbose=verbose)

    def is_server_ready(self) -> bool:
        return self.client.is_server_ready()

    def is_server_live(self) -> bool:
        return self.client.is_server_live()

    def load_model(self, model_name: str):
        return self.client.load_model(model_name=model_name)

    def unload_model(self, model_name: str):
        return self.client.unload_model(model_name=model_name)

    def is_model_ready(self, model_name: str, model_version: str | None = None) -> bool:
        if model_version is None:
            # 버전 인자를 아예 전달하지 않아야 Triton이 기본 버전 체크로 동작함
            return self.client.is_model_ready(model_name=model_name)

        # 버전이 있으면 string으로 변환
        return self.client.is_model_ready(model_name=model_name, model_version=str(model_version))

    def list_models(self) -> List[Dict]:
        return self.client.get_model_repository_index(as_json=True)


triton_client = TritonClient()
