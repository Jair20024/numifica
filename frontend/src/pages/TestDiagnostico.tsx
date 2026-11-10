
import { useState } from "react";
import { Link, useParams } from "react-router";
import { useQuery } from "@tanstack/react-query";

import { api } from "../api";
import type { Ejercicio } from "../api";

export default function TestDiagnostico() {
  const { temaId } = useParams();

  const [respuestas, setRespuestas] = useState<
    Record<number, number>
  >({});

  const {
    data: preguntas = [],
    isLoading,
    error,
  } = useQuery({
    queryKey: ["diagnostico-preguntas", temaId],
    queryFn: () =>
      api.get<Ejercicio[]>(
        `/temas/${temaId}/diagnostico/preguntas`
      ),
    retry: false,
  });

  if (isLoading) {
    return <p className="p-6">Cargando preguntas...</p>;
  }

  if (error) {
    return (
      <main className="mx-auto max-w-2xl p-6">
        <p className="text-red-600">
          No se pudieron cargar las preguntas.
        </p>
        <Link to="/" className="text-primario underline">
          Volver al inicio
        </Link>
      </main>
    );
  }

  const respondidas = Object.keys(respuestas).length;

  return (
    <main className="mx-auto max-w-2xl space-y-6 p-6">
      <h1 className="text-3xl font-extrabold">
        Test diagnóstico
      </h1>

      <p className="text-slate-600">
        Responde las 6 preguntas para conocer tu nivel.
        Este test no otorga XP.
      </p>

      <p className="font-bold">
        Preguntas respondidas: {respondidas} de {preguntas.length}
      </p>

      {preguntas.map((pregunta, indice) => (
        <section
          key={pregunta.id}
          className="rounded-2xl border border-borde bg-white p-6"
        >
          <h2 className="mb-4 font-bold">
            Pregunta {indice + 1}: {pregunta.enunciado}
          </h2>

          <div className="space-y-3">
            {pregunta.opciones.map((opcion) => (
              <label
                key={opcion.id}
                className="flex cursor-pointer gap-3 rounded-xl border p-3"
              >
                <input
                  type="radio"
                  name={`pregunta-${pregunta.id}`}
                  checked={
                    respuestas[pregunta.id] === opcion.id
                  }
                  onChange={() =>
                    setRespuestas((actuales) => ({
                      ...actuales,
                      [pregunta.id]: opcion.id,
                    }))
                  }
                />

                <span>{opcion.texto}</span>
              </label>
            ))}
          </div>
        </section>
      ))}

      <button
        type="button"
        disabled
        className="w-full rounded-xl bg-slate-400 px-6 py-3 font-bold text-white"
      >
        Entregar diagnóstico (próximamente)
      </button>
    </main>
  );
}
