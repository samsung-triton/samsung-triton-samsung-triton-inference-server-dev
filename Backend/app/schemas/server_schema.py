from app.schemas.base_schema import BaseRequest


class ServerActorRequest(BaseRequest):
    login_id: str
    description: str | None = None
