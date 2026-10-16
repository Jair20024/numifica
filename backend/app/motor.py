from sqlalchemy import func, select
from sqlalchemy.orm import Session, selectinload

from app.models import Ejercicio, Intento


def elegir_siguiente(db: Session, estudiante_id: int, tema_id: int) -> Ejercicio | None:
    """Ejercicio activo del tema que el estudiante no haya resuelto en sus últimos 10 intentos."""
    recientes = (
        select(Intento.ejercicio_id)
        .where(Intento.estudiante_id == estudiante_id)
        .order_by(Intento.fecha_hora.desc(), Intento.id.desc())
        .limit(10)
    )
    base = (
        select(Ejercicio)
        .options(selectinload(Ejercicio.opciones))
        .where(Ejercicio.tema_id == tema_id, Ejercicio.activo)
        .order_by(func.random())
        .limit(1)
    )
    ejercicio = db.scalar(base.where(Ejercicio.id.not_in(recientes)))
    if ejercicio is None:  # si no queda ninguno "nuevo", cualquiera del tema
        ejercicio = db.scalar(base)
    return ejercicio