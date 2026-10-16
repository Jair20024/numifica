import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

TZ = DateTime(timezone=True)


class Base(DeclarativeBase):
    pass


class Usuario(Base):
    __tablename__ = "usuario"

    id: Mapped[int] = mapped_column(primary_key=True)
    usuario: Mapped[str]
    contrasena_hash: Mapped[str]
    nombre: Mapped[str]
    alias: Mapped[str | None]
    rol: Mapped[str]
    xp_total: Mapped[int]
    xp_actualizado_en: Mapped[datetime] = mapped_column(TZ, server_default=func.now())


class SesionAuth(Base):
    __tablename__ = "sesion_auth"

    token: Mapped[str] = mapped_column(primary_key=True)  # guarda el hash SHA-256, no el token
    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuario.id"))
    creada_en: Mapped[datetime] = mapped_column(TZ, server_default=func.now())
    ultima_actividad: Mapped[datetime] = mapped_column(TZ, server_default=func.now())


class Tema(Base):
    __tablename__ = "tema"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str]


class Ejercicio(Base):
    __tablename__ = "ejercicio"

    id: Mapped[int] = mapped_column(primary_key=True)
    tema_id: Mapped[int] = mapped_column(ForeignKey("tema.id"))
    enunciado: Mapped[str]
    dificultad: Mapped[int]
    explicacion: Mapped[str]
    activo: Mapped[bool]

    opciones: Mapped[list["OpcionEjercicio"]] = relationship()


class OpcionEjercicio(Base):
    __tablename__ = "opcion_ejercicio"

    id: Mapped[int] = mapped_column(primary_key=True)
    ejercicio_id: Mapped[int] = mapped_column(ForeignKey("ejercicio.id"))
    texto: Mapped[str]
    es_correcta: Mapped[bool]


class Intento(Base):
    __tablename__ = "intento"

    id: Mapped[int] = mapped_column(primary_key=True)
    token_envio: Mapped[uuid.UUID]
    estudiante_id: Mapped[int] = mapped_column(ForeignKey("usuario.id"))
    ejercicio_id: Mapped[int] = mapped_column(ForeignKey("ejercicio.id"))
    opcion_id: Mapped[int] = mapped_column(ForeignKey("opcion_ejercicio.id"))
    es_correcto: Mapped[bool]
    tiempo_seg: Mapped[int]
    xp_ganado: Mapped[int]
    fecha_hora: Mapped[datetime] = mapped_column(TZ, server_default=func.now())