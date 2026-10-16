from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, practica, ranking

app = FastAPI(title="Numifica API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(practica.router)
app.include_router(ranking.router)

@app.get("/api/salud")
def salud():
    return {"estado": "ok"}