from typing import Any, List, Dict
import tritonclient.grpc as grpcclient
from app.core.config import settings


class TritonClient:
    def __init__(self, url: str = None, verbose: bool = False):
        self.client = grpcclient.InferenceServerClient(url=url or settings.TRITON_URL, verbose=verbose)

    def load_model(self, model_name: str):
        return self.client.load_model(model_name=model_name)

    def unload_model(self, model_name: str):
        return self.client.unload_model(model_name=model_name)

    def is_model_ready(self, model_name: str) -> bool:
        return self.client.is_model_ready(model_name)

    def list_models(self) -> List[Dict]:
        resp = self.client.get_model_repository_index(as_json=True)
 
        models = resp.get("models") if isinstance(resp, dict) else []
        if not isinstance(models, list):
            models = []

        out = []
        for m in models:
            state = m.get("state")
            out.append({
                "name": m.get("name"),
                "version": m.get("version"),
                "state": state,
                "reason": m.get("reason"),
                "ready": (state == "READY") if state is not None else False
            })

        return out

triton_client = TritonClient()
