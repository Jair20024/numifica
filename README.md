# Numifica

Sistema web gamificado y adaptativo para mejorar el rendimiento académico en Matemática de estudiantes de 6to grado de primaria. Proyecto de tesis de la Facultad de Ingeniería de Sistemas e Informática, Universidad Nacional Mayor de San Marcos (UNMSM).

> **Estado:** prototipo funcional (primera versión). Implementa el flujo del estudiante: inicio de sesión, práctica de ejercicios con retroalimentación inmediata, XP, rangos y tabla de clasificación. El motor adaptativo (reglas y ELO) y los paneles de docente, padre y administrador están pendientes.

## Pantallas implementadas

| ID | Pantalla | Descripción |
|---|---|---|
| P-01 | Inicio de sesión | Usuario y contraseña, con sesión por cookie |
| P-02 | Inicio del estudiante | Versión mínima: rango, XP y acceso a la práctica (tema fijo) |
| P-03 | Resolver ejercicio | Opción múltiple, barra de progreso "Ejercicio N de 10" |
| P-04 | Retroalimentación | Acierto (+XP) o error (respuesta correcta y explicación) |
| P-05 | Resumen de la práctica | Aciertos, XP ganado y rango |
| P-06 | Tabla de clasificación | Ranking por XP con la fila del estudiante resaltada |

## Tecnologías

| Componente | Tecnología |
|---|---|
| Frontend | React + TypeScript + Vite, Tailwind CSS, React Router, TanStack Query |
| Backend | FastAPI (Python 3.12) + Uvicorn, Pydantic, SQLAlchemy 2 |
| Base de datos | PostgreSQL |
| Seguridad | Argon2id (argon2-cffi), sesión en servidor con cookie HttpOnly |
| Gestión de paquetes | uv (Python) y npm (Node.js) |

## Estructura del repositorio

```
numifica/
├── db/
│   ├── schema.sql          # Tablas e índices
│   └── seed.sql            # Tema "Fracciones" con 12 ejercicios
├── backend/
│   ├── app/
│   │   ├── main.py         # Aplicación FastAPI y CORS
│   │   ├── config.py       # Configuración (.env)
│   │   ├── db.py           # Conexión a PostgreSQL
│   │   ├── models.py       # Modelos SQLAlchemy
│   │   ├── schemas.py      # Esquemas Pydantic
│   │   ├── security.py     # Hash Argon2id
│   │   ├── deps.py         # Sesión y verificación de roles
│   │   ├── gamificacion.py # XP, rangos y alias públicos
│   │   ├── motor.py        # Selección del siguiente ejercicio
│   │   └── routers/        # auth, practica, ranking
│   ├── crear_usuarios.py   # Usuarios de prueba
│   └── .env.example
└── frontend/
    └── src/                # Páginas, componentes y cliente de la API
```

## Requisitos previos

- [Git](https://git-scm.com/)
- [uv](https://docs.astral.sh/uv/) (instala Python 3.12 por su cuenta)
- [Node.js](https://nodejs.org/) (LTS)
- [PostgreSQL](https://www.postgresql.org/download/) 16 o superior

Los comandos están escritos para PowerShell (Windows). En macOS o Linux funcionan igual, salvo la sintaxis de variables de entorno.

## Instalación y ejecución

### 1. Clonar el repositorio

```powershell
git clone https://github.com/<tu-usuario>/numifica.git
cd numifica
```

### 2. Base de datos

```powershell
psql -U postgres -c "CREATE USER numifica_app WITH PASSWORD 'numifica_pass_dev';"
psql -U postgres -c "CREATE DATABASE numifica_db OWNER numifica_app;"

$env:PGCLIENTENCODING = "UTF8"
psql -U numifica_app -d numifica_db -f db/schema.sql
psql -U numifica_app -d numifica_db -f db/seed.sql
```

Las credenciales de arriba son **solo para desarrollo local**. Cámbialas en cualquier otro entorno.

### 3. Backend

```powershell
cd backend
uv sync
Copy-Item .env.example .env
uv run python crear_usuarios.py
uv run uvicorn app.main:app --reload
```

La API queda en `http://localhost:8000` y su documentación interactiva (Swagger) en `http://localhost:8000/docs`.

### 4. Frontend

En otra terminal:

```powershell
cd frontend
npm install
npm run dev
```

Abre `http://localhost:5173`. Vite reenvía `/api` al backend, por lo que no hay problemas de CORS ni de cookies en desarrollo.

## Usuarios de prueba

Todos usan la contraseña `mate1234` (solo desarrollo).

| Usuario | Rol | XP inicial |
|---|---|---|
| `rayo` | Estudiante | 340 |
| `luna` | Estudiante | 720 |
| `zorro` | Estudiante | 650 |
| `estrella` | Estudiante | 510 |
| `trueno` | Estudiante | 180 |
| `nube` | Estudiante | 90 |
| `profesor1` | Profesor | — |
| `admin` | Administrador | — |

En esta versión solo los estudiantes pueden practicar. El profesor puede ver el ranking.

## Gamificación

| Dificultad | XP por acierto | | Rango | XP mínimo |
|---|---|---|---|---|
| 1 (fácil) | 10 | | Aprendiz | 0 |
| 2 (media) | 15 | | Explorador | 100 |
| 3 (difícil) | 20 | | Estratega | 500 |
| | | | Maestro | 700 |

Una respuesta incorrecta no suma ni resta puntos. El ranking muestra alias, no nombres completos, y desempata por quién alcanzó antes ese XP.

## API REST

| Método | Endpoint | Rol | Descripción |
|---|---|---|---|
| GET | `/api/salud` | Público | Comprobación de estado |
| POST | `/api/auth/login` | Público | Inicia sesión y emite la cookie |
| GET | `/api/auth/me` | Todos | Datos del usuario autenticado |
| POST | `/api/auth/logout` | Todos | Cierra la sesión |
| GET | `/api/temas/{id}/siguiente` | Estudiante | Entrega un ejercicio del tema |
| POST | `/api/intentos` | Estudiante | Corrige la respuesta, suma XP y devuelve el siguiente ejercicio |
| GET | `/api/estudiantes/me/progreso` | Estudiante | XP, rango y XP faltante para el siguiente |
| GET | `/api/ranking` | Estudiante, Profesor | Tabla de clasificación |

## Decisiones de diseño

- **Sesiones en servidor, no JWT.** El navegador recibe un identificador aleatorio en una cookie `HttpOnly` y `SameSite=Lax`. La base de datos guarda solo su hash SHA-256. La sesión expira tras 30 minutos de inactividad.
- **Contraseñas con Argon2id**, nunca en texto plano.
- **Envíos idempotentes.** Cada respuesta lleva un `token_envio` (UUID) único. Si falla la conexión y el cliente reenvía, el servidor devuelve el resultado anterior sin duplicar el intento ni el XP.
- **El servidor nunca envía cuál opción es la correcta** antes de que el estudiante responda.
- **Motor adaptativo aislado en `motor.py`**, para reemplazar la selección aleatoria actual por reglas o ELO sin modificar el resto.

## Limitaciones conocidas

- El siguiente ejercicio se elige al azar entre las tres dificultades; la adaptación aún no está implementada.
- El servidor no verifica que el ejercicio respondido sea el que se entregó al estudiante, por lo que un cliente modificado podría sumar XP repitiendo ejercicios.
- El tema ("Fracciones") está fijo en el cliente.

## Pendiente

- [ ] Motor adaptativo (reglas y ELO) y test de entrada
- [ ] Paneles de docente, padre y administrador
- [ ] Pruebas automatizadas (pytest y Playwright)
- [ ] Despliegue con Docker Compose y Caddy
- [ ] Pruebas de carga (JMeter), medición (Lighthouse) y monitoreo (UptimeRobot)

## Autor

Jair Stefano Becerra Carrillo, Universidad Nacional Mayor de San Marcos.
Asesor: Daniel Alfonso Quinto Pazce.

## Licencia

Por definir.