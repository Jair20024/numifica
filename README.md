
# Numifica

Aplicación web de práctica matemática con evaluaciones diagnósticas, resolución interactiva de ejercicios y gamificación.

Implementada mediante una arquitectura cliente-servidor, con frontend SPA en React, API REST en FastAPI y persistencia relacional en PostgreSQL.

## Stack tecnológico

| Componente | Tecnologías |
|---|---|
| Frontend | React 19, TypeScript, Vite 8 |
| UI | Tailwind CSS 4, Nunito |
| Routing | React Router 8 |
| Estado del servidor | TanStack Query 5 |
| Backend | Python 3.12+, FastAPI, Uvicorn |
| Validación | Pydantic |
| ORM | SQLAlchemy 2 |
| Base de datos | PostgreSQL, psycopg 3 |
| Autenticación | Argon2id, SHA-256, cookies HttpOnly |
| Gestión de dependencias | uv, npm |

## Funcionalidades

### Autenticación y autorización
- Autenticación mediante usuario y contraseña.
- Sesiones persistidas en PostgreSQL.
- Control de acceso basado en roles mediante dependencias de FastAPI.
- Expiración de sesiones por inactividad.

### Evaluación diagnóstica
- Diagnóstico independiente por estudiante y tema.
- Asignación de 6 ejercicios: 2 por nivel de dificultad.
- Persistencia de preguntas asignadas y resultados.
- Corrección automática y clasificación en niveles `BASICO`, `INTERMEDIO` y `AVANZADO`.
- Restricción de unicidad por estudiante y tema.

### Práctica matemática
- Banco de ejercicios organizado por competencias, temas y dificultades.
- Sesiones de 15 ejercicios de opción múltiple.
- Selección aleatoria de ejercicios activos, excluyendo cuando es posible los últimos 10 intentos.
- Corrección y retroalimentación inmediata.
- Registro de respuestas, tiempo empleado y XP obtenido.

### Gamificación
- XP según dificultad: 10, 15 y 20 puntos.
- Rangos: Aprendiz, Explorador, Estratega y Maestro.
- Ranking ordenado por XP acumulado.
- Seguimiento del progreso individual.

## Arquitectura

```text
frontend/
  React + TypeScript
         |
         | HTTP / JSON
         v
backend/
  FastAPI
    |
    +-- routers/       Endpoints REST
    +-- deps.py        Autenticación y autorización
    +-- security.py    Hash de contraseñas y tokens
    +-- motor.py       Selección de ejercicios
    +-- gamificacion.py
    |
    v
  SQLAlchemy 2
    |
    v
  PostgreSQL
```

El frontend utiliza TanStack Query para gestionar las consultas y mutaciones HTTP. Vite configura un proxy de `/api` hacia FastAPI durante el desarrollo.

## Estructura del repositorio

```text
numifica/
├── backend/
│   ├── app/
│   │   ├── routers/
│   │   │   ├── auth.py
│   │   │   ├── temas.py
│   │   │   ├── diagnostico.py
│   │   │   ├── practica.py
│   │   │   └── ranking.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   ├── db.py
│   │   ├── deps.py
│   │   ├── security.py
│   │   ├── motor.py
│   │   ├── gamificacion.py
│   │   └── main.py
│   ├── crear_usuarios.py
│   └── pyproject.toml
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   ├── components/
│   │   ├── api.ts
│   │   └── App.tsx
│   └── package.json
├── db/
│   ├── schema.sql
│   └── seed.sql
└── README.md
```

## Instalación y ejecución

**Requisitos:** Python 3.12+, uv, Node.js y PostgreSQL.

### 1. Clonar el repositorio

```bash
git clone https://github.com/Jair20024/numifica.git
cd numifica
```

### 2. Base de datos

Crear una base de datos PostgreSQL llamada `numifica_db` y un usuario con permisos sobre ella.

Ejecutar los scripts SQL en orden:

```bash
psql -U numifica_app -d numifica_db -f db/schema.sql
psql -U numifica_app -d numifica_db -f db/seed.sql
```

### 3. Backend

```bash
cd backend
uv sync
```

Crear `backend/.env`:

```dotenv
DATABASE_URL=postgresql+psycopg://USUARIO:CONTRASENA@localhost:5432/numifica_db
FRONTEND_ORIGIN=http://localhost:5173
SESSION_MINUTES=30
COOKIE_SECURE=false
```

Inicializar usuarios de desarrollo:

```bash
uv run python crear_usuarios.py
```

Iniciar el servidor:

```bash
uv run uvicorn app.main:app --reload
```

API: `http://localhost:8000`

Documentación OpenAPI: `http://localhost:8000/docs`

### 4. Frontend

En otra terminal, desde la raíz del repositorio:

```bash
cd frontend
npm install
npm run dev
```

Aplicación: `http://localhost:5173`

## API REST

| Método | Endpoint | Descripción |
|---|---|---|
| POST | `/api/auth/login` | Crear sesión |
| GET | `/api/auth/me` | Obtener usuario autenticado |
| POST | `/api/auth/logout` | Cerrar sesión |
| GET | `/api/temas` | Listar temas |
| GET | `/api/temas/{tema_id}/diagnostico/estado` | Consultar diagnóstico |
| GET | `/api/temas/{tema_id}/diagnostico/preguntas` | Obtener preguntas asignadas |
| POST | `/api/temas/{tema_id}/diagnostico/entregar` | Evaluar diagnóstico |
| GET | `/api/temas/{tema_id}/siguiente` | Seleccionar ejercicio |
| POST | `/api/intentos` | Corregir y registrar intento |
| GET | `/api/estudiantes/me/progreso` | Consultar XP y rango |
| GET | `/api/ranking` | Obtener clasificación |

## Persistencia y seguridad

El esquema relacional se define en `db/schema.sql` e incluye las entidades `usuario`, `sesion_auth`, `competencia`, `tema`, `ejercicio`, `opcion_ejercicio`, `intento`, `diagnostico` y `diagnostico_pregunta`.

- **Contraseñas:** hash Argon2id mediante `argon2-cffi`.
- **Sesiones:** token aleatorio almacenado en una cookie `HttpOnly` y `SameSite=Lax`; hash SHA-256 persistido en PostgreSQL.
- **Autorización:** validación de roles con `Depends()` de FastAPI.
- **Integridad:** claves foráneas, restricciones `UNIQUE` y `CHECK`.
- **Idempotencia:** identificador UUID `token_envio` para evitar registros duplicados de intentos y XP.
- **Transacciones:** persistencia de intentos y actualización de XP mediante SQLAlchemy.
- **Validación:** contratos de entrada y salida definidos con Pydantic.
