from datetime import datetime, timezone

from sqlalchemy import select

from app.db import SessionLocal
from app.models import Usuario
from app.security import hash_password

CONTRASENA_DEV = "mate1234"  # solo para desarrollo

USUARIOS = [
    # usuario, nombre, alias, rol, xp
    ("rayo",      "Mateo Rojas",      "Rayo M.",    "ESTUDIANTE", 340),
    ("luna",      "Lucía Ramos",      "Luna R.",    "ESTUDIANTE", 720),
    ("zorro",     "Andrés Salazar",   "Zorro A.",   "ESTUDIANTE", 650),
    ("estrella",  "Valeria Quispe",   "Estrella V.", "ESTUDIANTE", 510),
    ("trueno",    "Diego Flores",     "Trueno D.",  "ESTUDIANTE", 180),
    ("nube",      "Camila Torres",    "Nube C.",    "ESTUDIANTE", 90),
    ("profesor1", "Profesor de Prueba", None,       "PROFESOR",   0),
    ("admin",     "Administrador",    None,         "ADMINISTRADOR", 0),
]

with SessionLocal() as db:
    creados = 0
    for usuario, nombre, alias, rol, xp in USUARIOS:
        if db.scalar(select(Usuario).where(Usuario.usuario == usuario)):
            continue
        db.add(Usuario(
            usuario=usuario,
            contrasena_hash=hash_password(CONTRASENA_DEV),
            nombre=nombre,
            alias=alias,
            rol=rol,
            xp_total=xp,
            xp_actualizado_en=datetime.now(timezone.utc),
        ))
        creados += 1
    db.commit()
    print(f"Usuarios creados: {creados}")