import uuid

from pydantic import BaseModel, Field


class OpcionOut(BaseModel):
    id: int
    texto: str  # nunca se envía es_correcta al navegador


class EjercicioOut(BaseModel):
    id: int
    enunciado: str
    dificultad: int
    opciones: list[OpcionOut]


class IntentoIn(BaseModel):
    token_envio: uuid.UUID
    ejercicio_id: int
    opcion_id: int
    tiempo_seg: int = Field(ge=0, le=3600)


class ResultadoOut(BaseModel):
    es_correcto: bool
    xp_ganado: int
    xp_total: int
    rango: str
    respuesta_correcta: str | None  # solo si falló
    explicacion: str | None         # solo si falló
    siguiente: EjercicioOut | None


class ProgresoOut(BaseModel):
    xp_total: int
    rango: str
    siguiente_rango: str | None
    xp_para_siguiente: int | None


class RankingFila(BaseModel):
    posicion: int
    alias: str
    rango: str
    xp: int
    es_yo: bool