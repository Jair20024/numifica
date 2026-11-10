from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db import get_db
from app.deps import requiere_rol
from app.models import Tema, Usuario
from app.schemas import TemaOut

router = APIRouter(prefix="/api", tags=["temas"])


@router.get("/temas", response_model=list[TemaOut])
def listar_temas(
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    temas = db.scalars(
        select(Tema).order_by(Tema.id)
    ).all()

    return [
        TemaOut(
            id=tema.id,
            nombre=tema.nombre,
            competencia=tema.competencia.nombre,
        )
        for tema in temas
    ]
