import hashlib

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerifyMismatchError

_ph = PasswordHasher()  # Argon2id por defecto

# Se usa cuando el usuario no existe, para que la respuesta tarde lo mismo
DUMMY_HASH = _ph.hash("contrasena-falsa")


def hash_password(contrasena: str) -> str:
    return _ph.hash(contrasena)


def verify_password(hash_guardado: str, contrasena: str) -> bool:
    try:
        return _ph.verify(hash_guardado, contrasena)
    except (VerifyMismatchError, InvalidHashError):
        return False


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()