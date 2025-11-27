from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.schemas.masterkey_schema import MasterKeyVarifyRequest
from app.core.DB.database import get_db
from app.services.masterkey_service import varify_mastekey_service
from app.schemas.base_schema import BaseResponse

mastekey_router = APIRouter(prefix="/masterkey", tags=["MasterKey"])


@mastekey_router.post("/verify", response_model=BaseResponse)
def varify_mastekey(request: MasterKeyVarifyRequest, db: Session = Depends(get_db)):
    return varify_mastekey_service(request.master_key, db)
