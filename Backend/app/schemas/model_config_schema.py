from app.schemas.base_schema import BaseRequest


class ConfigUpdateRequest(BaseRequest):
    login_id: str
    description: str | None = None
    config_content: str


class ConfigDeleteRequest(BaseRequest):
    login_id: str
    description: str | None = None
