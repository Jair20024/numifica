import { Link } from "react-router";
import { useQuery } from "@tanstack/react-query";
import { api } from "../api";
import type { Progreso, Tema } from "../api";
import { useUsuario } from "../auth";


export default function Inicio() {
  const { data: usuario } = useUsuario();
  const esEstudiante = usuario?.rol === "ESTUDIANTE";

  const { data: progreso } = useQuery({
    queryKey: ["progreso"],
    queryFn: () => api.get<Progreso>("/estudiantes/me/progreso"),
    enabled: esEstudiante,
  });

    const {
    data: temas = [],
    isLoading: cargandoTemas,
    error: errorTemas,
  } = useQuery({
    queryKey: ["temas"],
    queryFn: () => api.get<Tema[]>("/temas"),
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


<section className="space-y-4">
  <h2 className="text-2xl font-extrabold">
    Temas de Matemática
  </h2>

  {cargandoTemas && <p>Cargando temas...</p>}

  {errorTemas && (
    <p role="alert" className="text-error">
      No se pudieron cargar los temas.
    </p>
  )}

  <div className="grid gap-4 md:grid-cols-2">
    {temas.map((tema) => (
      <article
        key={tema.id}
        className="rounded-2xl border border-borde bg-white p-6"
      >
        <h3 className="text-xl font-extrabold">
          {tema.nombre}
        </h3>

        <p className="mt-2 text-sm text-slate-600">
          Competencia: {tema.competencia}
        </p>

        <Link
          to={`/practicar/${tema.id}`}
          className="mt-5 inline-block rounded-xl bg-primario
                     px-6 py-3 font-extrabold text-white
                     hover:bg-primario-oscuro"
        >
          Practicar
        </Link>
      </article>
    ))}
  </div>
</section>
    </div>
  );
}