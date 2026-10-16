from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db import get_db
from app.deps import requiere_rol
from app.gamificacion import nombre_publico, rango_de, siguiente_rango
from app.models import Usuario
from app.schemas import ProgresoOut, RankingFila

router = APIRouter(prefix="/api", tags=["ranking"])


@router.get("/ranking", response_model=list[RankingFila])
def ranking(
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE", "PROFESOR")),
    db: Session = Depends(get_db),
):
    # Desempate: quien llegó antes a ese XP queda arriba
    estudiantes = db.scalars(
        select(Usuario)
        .where(Usuario.rol == "ESTUDIANTE")
        .order_by(Usuario.xp_total.desc(), Usuario.xp_actualizado_en.asc(), Usuario.id.asc())
    ).all()
    return [
        RankingFila(
            posicion=i,
            alias=nombre_publico(e.alias, e.nombre),
            rango=rango_de(e.xp_total),
            xp=e.xp_total,
            es_yo=e.id == usuario.id,
        )
        for i, e in enumerate(estudiantes, start=1)
    ]


@router.get("/estudiantes/me/progreso", response_model=ProgresoOut)
def mi_progreso(usuario: Usuario = Depends(requiere_rol("ESTUDIANTE"))):
    xp = db_xp = usuario.xp_total
    sig = siguiente_rango(xp)
    return ProgresoOut(
        xp_total=db_xp,
        rango=rango_de(xp),
        siguiente_rango=sig[0] if sig else None,
        xp_para_siguiente=sig[1] if sig else None,
    )