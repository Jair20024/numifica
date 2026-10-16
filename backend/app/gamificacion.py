XP_POR_DIFICULTAD = {1: 10, 2: 15, 3: 20}

RANGOS = [  # (nombre, xp mínimo), de menor a mayor
    ("Aprendiz", 0),
    ("Explorador", 100),
    ("Estratega", 500),
    ("Maestro", 700),
]


def rango_de(xp: int) -> str:
    actual = RANGOS[0][0]
    for nombre, minimo in RANGOS:
        if xp >= minimo:
            actual = nombre
    return actual


def siguiente_rango(xp: int) -> tuple[str, int] | None:
    """Devuelve (nombre, xp que faltan) o None si ya es el rango máximo."""
    for nombre, minimo in RANGOS:
        if minimo > xp:
            return nombre, minimo - xp
    return None


def nombre_publico(alias: str | None, nombre: str) -> str:
    """Alias si existe; si no, nombre e inicial del apellido."""
    if alias:
        return alias
    partes = nombre.split()
    return f"{partes[0]} {partes[-1][0]}." if len(partes) > 1 else partes[0]