from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.config import settings
from app.db import get_db
from app.models import SesionAuth, Usuario
from app.security import hash_token

COOKIE_NAME = "numifica_sid"


def get_usuario_actual(request: Request, db: Session = Depends(get_db)) -> Usuario:
    token = request.cookies.get(COOKIE_NAME)
    if not token:
        raise HTTPException(status_code=401, detail="No autenticado")

    ahora = datetime.now(timezone.utc)
    sesion = db.get(SesionAuth, hash_token(token))
    if sesion is None:
        raise HTTPException(status_code=401, detail="No autenticado")

    if ahora - sesion.ultima_actividad > timedelta(minutes=settings.session_minutes):
        db.delete(sesion)
        db.commit()
        raise HTTPException(status_code=401, detail="Sesión expirada")

    sesion.ultima_actividad = ahora  # la expiración se cuenta desde la última actividad
    db.commit()
    return db.get(Usuario, sesion.usuario_id)


def requiere_rol(*roles: str):
    def dependencia(usuario: Usuario = Depends(get_usuario_actual)) -> Usuario:
        if usuario.rol not in roles:
            raise HTTPException(status_code=403, detail="No tienes permiso para esto")
        return usuario

    return dependencia