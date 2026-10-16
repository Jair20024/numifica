import { Link } from "react-router";
import { useQuery } from "@tanstack/react-query";
import { api } from "../api";
import type { Progreso } from "../api";
import { useUsuario } from "../auth";

export default function Inicio() {
  const { data: usuario } = useUsuario();
  const esEstudiante = usuario?.rol === "ESTUDIANTE";

  const { data: progreso } = useQuery({
    queryKey: ["progreso"],
    queryFn: () => api.get<Progreso>("/estudiantes/me/progreso"),
    enabled: esEstudiante,
  });

  if (!usuario) return null;

  if (!esEstudiante) {
    return (
      <p className="rounded-2xl border border-borde bg-white p-6">
        Esta versión solo incluye las pantallas del estudiante. Puedes ver el{" "}
        <Link to="/ranking" className="font-bold text-primario underline">ranking</Link>.
      </p>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-extrabold">¡Hola, {usuario.alias ?? usuario.nombre}!</h1>

      {progreso && (
        <section className="rounded-2xl border border-borde bg-white p-6">
          <p className="text-lg">
            Rango: <strong>{progreso.rango}</strong> · <strong>{progreso.xp_total} XP</strong>
          </p>
          <p className="mt-1 text-slate-600">
            {progreso.siguiente_rango
              ? `Te faltan ${progreso.xp_para_siguiente} XP para ser ${progreso.siguiente_rango}.`
              : "¡Llegaste al rango máximo!"}
          </p>
        </section>
      )}

      <section className="rounded-2xl border border-borde bg-white p-6">
        <h2 className="text-xl font-extrabold">Fracciones</h2>
        <p className="mt-1 text-slate-600">Practica y gana XP por cada acierto.</p>
        <Link
          to="/practicar/1"
          className="mt-4 inline-block rounded-xl bg-primario px-6 py-3 font-extrabold text-white
                     hover:bg-primario-oscuro"
        >
          Practicar
        </Link>
      </section>
    </div>
  );
}