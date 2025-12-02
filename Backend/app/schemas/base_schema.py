from pydantic import BaseModel, ConfigDict


def to_camel(string: str) -> str:
    parts = string.split("_")
    return parts[0] + "".join(word.capitalize() for word in parts[1:])


class BaseRequest(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,  # snake_case로도 값 넣기 허용
        alias_generator=to_camel,  # camelCase 입력 허용
    )


class BaseResponse(BaseModel):
    code: str
    message: str
    data: dict | None = None
