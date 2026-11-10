
import random

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, selectinload

from app.db import get_db
from app.deps import requiere_rol

from app.models import (
    Diagnostico,
    DiagnosticoPregunta,
    Ejercicio,
    OpcionEjercicio,
    Tema,
    Usuario,
)

router = APIRouter(prefix="/api", tags=["diagnostico"])


class RespuestaIn(BaseModel):
    ejercicio_id: int
    opcion_id: int


class EntregaIn(BaseModel):
    respuestas: list[RespuestaIn]


def calcular_nivel(aciertos: int) -> str:
    if aciertos <= 2:
        return "BASICO"
    if aciertos <= 4:
        return "INTERMEDIO"
    return "AVANZADO"


@router.get("/temas/{tema_id}/diagnostico/estado")
def estado_diagnostico(
    tema_id: int,
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    resultado = db.scalar(
        select(Diagnostico).where(
            Diagnostico.estudiante_id == usuario.id,
            Diagnostico.tema_id == tema_id,
        )
    )
    return {
        "completado": resultado is not None,
        "aciertos": resultado.aciertos if resultado else None,
        "nivel": resultado.nivel if resultado else None,
    }



@router.get("/temas/{tema_id}/diagnostico/preguntas")
def preguntas_diagnostico(
    tema_id: int,
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    if db.scalar(
        select(Diagnostico.id).where(
            Diagnostico.estudiante_id == usuario.id,
            Diagnostico.tema_id == tema_id,
        )
    ) is not None:
        raise HTTPException(409, "Ya completaste este diagnóstico")

    if db.get(Tema, tema_id) is None:
        raise HTTPException(404, "Tema no encontrado")

    ids_guardados = db.scalars(
        select(DiagnosticoPregunta.ejercicio_id).where(
            DiagnosticoPregunta.estudiante_id == usuario.id,
            DiagnosticoPregunta.tema_id == tema_id,
        )
    ).all()

    if ids_guardados:
        if len(ids_guardados) != 6:
            raise HTTPException(409, "El diagnóstico tiene preguntas incompletas")

        preguntas = db.scalars(
            select(Ejercicio)
            .options(selectinload(Ejercicio.opciones))
            .where(Ejercicio.id.in_(ids_guardados))
        ).all()
    else:
        preguntas = []

        for dificultad in (1, 2, 3):
            ejercicios = db.scalars(
                select(Ejercicio)
                .options(selectinload(Ejercicio.opciones))
                .where(
                    Ejercicio.tema_id == tema_id,
                    Ejercicio.activo.is_(True),
                    Ejercicio.dificultad == dificultad,
                )
            ).all()

            if len(ejercicios) < 2:
                raise HTTPException(
                    409, "El tema necesita al menos 2 ejercicios por dificultad"
                )

            preguntas.extend(random.sample(ejercicios, 2))

        for ejercicio in preguntas:
            db.add(
                DiagnosticoPregunta(
                    estudiante_id=usuario.id,
                    tema_id=tema_id,
                    ejercicio_id=ejercicio.id,
                )
            )

        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(
                409, "Las preguntas ya fueron asignadas. Recarga la página"
            )

    if len(preguntas) != 6:
        raise HTTPException(409, "No se pudieron recuperar las 6 preguntas")

    return [
        {
            "id": e.id,
            "enunciado": e.enunciado,
            "dificultad": e.dificultad,
            "opciones": [
                {"id": o.id, "texto": o.texto}
                for o in random.sample(e.opciones, len(e.opciones))
            ],
        }
        for e in preguntas
    ]


@router.post("/temas/{tema_id}/diagnostico/entregar")
def entregar_diagnostico(
    tema_id: int,
    datos: EntregaIn,
    usuario: Usuario = Depends(requiere_rol("ESTUDIANTE")),
    db: Session = Depends(get_db),
):
    if db.get(Tema, tema_id) is None:
        raise HTTPException(404, "Tema no encontrado")

    existente = db.scalar(select(Diagnostico).where(
        Diagnostico.estudiante_id == usuario.id,
        Diagnostico.tema_id == tema_id,
    ))
    if existente:
        raise HTTPException(409, "Ya completaste este diagnóstico")

    ids = [r.ejercicio_id for r in datos.respuestas]
    if len(ids) != 6 or len(set(ids)) != 6:
        raise HTTPException(400, "Debes responder 6 ejercicios distintos")

    ids_asignados = db.scalars(
        select(DiagnosticoPregunta.ejercicio_id).where(
            DiagnosticoPregunta.estudiante_id == usuario.id,
            DiagnosticoPregunta.tema_id == tema_id,
        )
    ).all()

    if len(ids_asignados) != 6 or set(ids) != set(ids_asignados):
        raise HTTPException(
            400,
            "Debes responder exactamente las 6 preguntas asignadas",
        )

    ejercicios = db.scalars(
        select(Ejercicio).where(
            Ejercicio.id.in_(ids),
            Ejercicio.tema_id == tema_id,
            Ejercicio.activo.is_(True),
        )
    ).all()

    if len(ejercicios) != 6:
        raise HTTPException(400, "Hay ejercicios inválidos")

    cantidades = [sum(e.dificultad == d for e in ejercicios)
                  for d in (1, 2, 3)]
    if cantidades != [2, 2, 2]:
        raise HTTPException(400, "Se requieren 2 ejercicios por dificultad")

    opciones = db.scalars(
        select(OpcionEjercicio).where(
            OpcionEjercicio.id.in_([r.opcion_id for r in datos.respuestas])
        )
    ).all()
    mapa_opciones = {o.id: o for o in opciones}

    aciertos = 0
    for respuesta in datos.respuestas:
        opcion = mapa_opciones.get(respuesta.opcion_id)
        if opcion is None or opcion.ejercicio_id != respuesta.ejercicio_id:
            raise HTTPException(400, "Una respuesta no pertenece al ejercicio")
        if opcion.es_correcta:
            aciertos += 1

    nivel = calcular_nivel(aciertos)
    db.add(Diagnostico(
        estudiante_id=usuario.id,
        tema_id=tema_id,
        aciertos=aciertos,
        nivel=nivel,
    ))

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "El diagnóstico ya fue registrado")

    return {"completado": True, "aciertos": aciertos, "nivel": nivel}
