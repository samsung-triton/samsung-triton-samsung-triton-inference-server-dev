from typing import Optional, Dict, Any
from app.clients.triton_grpc import TritonGrpc

class HealthMetaService:
    """Triton의 health, server metadata, model ready 확인 전용 서비스."""
    def __init__(self, url: Optional[str] = None, verbose: bool = False):
        self.triton = TritonGrpc(url=url, verbose=verbose)

    def health_summary(self) -> Dict[str, Any]:
        meta = self.triton.get_server_metadata()
        return {
            "live": self.triton.is_server_live(),
            "ready": self.triton.is_server_ready(),
            "server": {"name": meta.name, "version": meta.version},
        }

    def server_metadata(self) -> Dict[str, Any]:
        m = self.triton.get_server_metadata()
        return {"name": m.name, "version": m.version, "extensions": list(m.extensions)}

    def model_ready(self, name: str, version: Optional[str] = None) -> bool:
        return self.triton.is_model_ready(name, version or "")
