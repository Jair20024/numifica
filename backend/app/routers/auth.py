import secrets

from fastapi import APIRouter, Depends, HTTPException, Request, Response
from pydantic import BaseModel, ConfigDict
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import settings
from app.db import get_db
from app.deps import COOKIE_NAME, get_usuario_actual
from app.models import SesionAuth, Usuario
from app.security import DUMMY_HASH, hash_token, verify_password

router = APIRouter(prefix="/api/auth", tags=["auth"])


class LoginIn(BaseModel):
    usuario: str
    contrasena: str


class UsuarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nombre: str
    alias: str | None
    rol: str


@router.post("/login", response_model=UsuarioOut)
def login(datos: LoginIn, response: Response, db: Session = Depends(get_db)):
    usuario = db.scalar(select(Usuario).where(Usuario.usuario == datos.usuario))
    hash_guardado = usuario.contrasena_hash if usuario else DUMMY_HASH
    contrasena_ok = verify_password(hash_guardado, datos.contrasena)

    if usuario is None or not contrasena_ok:
        raise HTTPException(status_code=401, detail="Usuario o contraseña incorrectos")

    token = secrets.token_urlsafe(32)
    db.add(SesionAuth(token=hash_token(token), usuario_id=usuario.id))
    db.commit()

    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        httponly=True,
        samesite="lax",
        secure=settings.cookie_secure,
    )
    return usuario


@router.get("/me", response_model=UsuarioOut)
def me(usuario: Usuario = Depends(get_usuario_actual)):
    return usuario


@router.post("/logout")
def logout(request: Request, response: Response, db: Session = Depends(get_db)):
    token = request.cookies.get(COOKIE_NAME)
    if token:
        sesion = db.get(SesionAuth, hash_token(token))
        if sesion:
            db.delete(sesion)
            db.commit()
    response.delete_cookie(COOKIE_NAME)
    return {"ok": True}