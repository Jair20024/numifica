import { queryClient } from "./queryClient";

export type Usuario = {
  id: number;
  nombre: string;
  alias: string | null;
  rol: string;
};

export type FilaRanking = {
  posicion: number;
  alias: string;
  rango: string;
  xp: number;
  es_yo: boolean;
};

export type Progreso = {
  xp_total: number;
  rango: string;
  siguiente_rango: string | null;
  xp_para_siguiente: number | null;
};

export type Opcion = { id: number; texto: string };

export type Ejercicio = {
  id: number;
  enunciado: string;
  dificultad: number;
  opciones: Opcion[];
};

export type Resultado = {
  es_correcto: boolean;
  xp_ganado: number;
  xp_total: number;
  rango: string;
  respuesta_correcta: string | null;
  explicacion: string | null;
  siguiente: Ejercicio | null;
};

export class ApiError extends Error {
  status: number;

  constructor(status: number, mensaje: string) {
    super(mensaje);
    this.status = status;
  }
}

async function pedir<T>(metodo: string, ruta: string, cuerpo?: unknown): Promise<T> {
  let resp: Response;
  try {
    resp = await fetch(`/api${ruta}`, {
      method: metodo,
      headers: cuerpo !== undefined ? { "Content-Type": "application/json" } : undefined,
      body: cuerpo !== undefined ? JSON.stringify(cuerpo) : undefined,
    });
  } catch {
    throw new ApiError(0, "No hay conexión con el servidor");
  }

  if (!resp.ok) {
    let detalle = "Ocurrió un error, inténtalo de nuevo";
    try {
      const datos = await resp.json();
      if (typeof datos.detail === "string") detalle = datos.detail;
    } catch {
      /* la respuesta no era JSON */
    }
    // Sesión expirada: volver al login (el login y /me manejan su propio 401)
    if (resp.status === 401 && ruta !== "/auth/login" && ruta !== "/auth/me") {
      queryClient.setQueryData(["me"], null);
    }
    throw new ApiError(resp.status, detalle);
  }
  return resp.json() as Promise<T>;
}

export const api = {
  get: <T>(ruta: string) => pedir<T>("GET", ruta),
  post: <T>(ruta: string, cuerpo?: unknown) => pedir<T>("POST", ruta, cuerpo),
};