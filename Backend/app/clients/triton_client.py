import tritonclient.grpc as grpcclient
from typing import List, Dict

from app.core.config import settings


class TritonClient:
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
            # Triton이 요구하는 기본값 ""
            model_version = ""
        else:
            # 숫자로 넘어오면 강제 str()
            model_version = str(model_version)
        return self.client.is_model_ready(model_name=model_name, model_version=model_version)

    def list_models(self) -> List[Dict]:
        return self.client.get_model_repository_index(as_json=True)


triton_client = TritonClient()
