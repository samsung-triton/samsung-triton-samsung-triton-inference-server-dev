from fastapi import HTTPException


class CustomHTTPException(HTTPException):
    def __init__(
        self,
        status_code: int,
        code: str,
        message: str,
        data: dict | None = None,
    ):
        self.code = code
        self.message = message
        self.data = data
        super().__init__(status_code=status_code, detail=None)
