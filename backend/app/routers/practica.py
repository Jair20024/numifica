import random

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db import get_db
from app.deps import requiere_rol
from app.gamificacion import XP_POR_DIFICULTAD, rango_de
from app.models import Ejercicio, Intento, OpcionEjercicio, Usuario
from app.motor import elegir_siguiente
from app.schemas import EjercicioOut, IntentoIn, OpcionOut, ResultadoOut

router = APIRouter(prefix="/api", tags=["practica"])


def _ejercicio_out(ejercicio: Ejercicio) -> EjercicioOut:
    opciones = [OpcionOut(id=o.id, texto=o.texto) for o in ejercicio.opciones]
    random.shuffle(opciones)  # que la correcta no quede siempre en la misma posición
    return EjercicioOut(
        id=ejercicio.id,
        enunciado=ejercicio.enunciado,
        dificultad=ejercicio.dificultad,
        opciones=opciones,
    )


def _resultado(db: Session, usuario: Usuario, intento: Intento) -> ResultadoOut:
    ejercicio = db.get(Ejercicio, intento.ejercicio_id)
    xp_total = db.scalar(select(Usuario.xp_total).where(Usuario.id == usuario.id))

    respuesta_correcta = None
    explicacion = None
    if not intento.es_correcto:
        respuesta_correcta = db.scalar(
            select(OpcionEjercicio.texto).where(
                OpcionEjercicio.ejercicio_id == ejercicio.id,
                OpcionEjercicio.es_correcta,
            )
        )
        explicacion = ejercicio.explicacion

    siguiente = elegir_siguiente(db, usuario.id, ejercicio.tema_id)
    return ResultadoOut(
        es_correcto=intento.es_correcto,
        xp_ganado=intento.xp_ganado,
        xp_total=xp_total,
        rango=rango_de(xp_total),
        respuesta_correcta=respuesta_correcta,
        explicacion=explicacion,
        siguiente=_ejercicio_out(siguiente) if siguiente else None,
    )


@router.get("/temas/{tema_id}/siguiente", response_model=EjercicioOut)
def siguiente_ejercicio(
    tema_id: int,
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    ejercicio = elegir_siguiente(db, usuario.id, tema_id)
    if ejercicio is None:
        raise HTTPException(status_code=404, detail="Este tema no tiene ejercicios disponibles")
    return _ejercicio_out(ejercicio)


@router.post("/intentos", response_model=ResultadoOut)
def enviar_intento(
    datos: IntentoIn,
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    # 1) Duplicado: si el token ya se guardó, devolver el resultado anterior sin registrar nada
    previo = db.scalar(select(Intento).where(Intento.token_envio == datos.token_envio))
    if previo:
        if previo.estudiante_id != usuario.id:
            raise HTTPException(status_code=409, detail="Token de envío ya utilizado")
        return _resultado(db, usuario, previo)

    # 2) Validar ejercicio y opción
    ejercicio = db.get(Ejercicio, datos.ejercicio_id)
    if ejercicio is None or not ejercicio.activo:
        raise HTTPException(status_code=404, detail="Ejercicio no encontrado")
    opcion = db.get(OpcionEjercicio, datos.opcion_id)
    if opcion is None or opcion.ejercicio_id != ejercicio.id:
        raise HTTPException(status_code=400, detail="La opción no pertenece al ejercicio")

    # 3) Corregir y calcular XP (solo si acierta; si falla no se resta nada)
    es_correcto = opcion.es_correcta
    xp = XP_POR_DIFICULTAD[ejercicio.dificultad] if es_correcto else 0

    # 4) Guardar intento y sumar XP en una sola transacción
    intento = Intento(
        token_envio=datos.token_envio,
        estudiante_id=usuario.id,
        ejercicio_id=ejercicio.id,
        opcion_id=opcion.id,
        es_correcto=es_correcto,
        tiempo_seg=datos.tiempo_seg,
        xp_ganado=xp,
    )
    db.add(intento)
    try:
        db.flush()
    except IntegrityError:  # dos envíos idénticos casi a la vez: gana el primero
        db.rollback()
        previo = db.scalar(select(Intento).where(Intento.token_envio == datos.token_envio))
        if previo and previo.estudiante_id == usuario.id:
            return _resultado(db, usuario, previo)
        raise HTTPException(status_code=409, detail="Token de envío ya utilizado")

    if xp > 0:
        db.execute(
            update(Usuario)
            .where(Usuario.id == usuario.id)
            .values(xp_total=Usuario.xp_total + xp, xp_actualizado_en=func.now())
        )
    db.commit()
    return _resultado(db, usuario, intento)