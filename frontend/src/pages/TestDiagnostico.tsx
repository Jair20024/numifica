
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

  const [resultado, setResultado] = useState<{
    aciertos: number;
    nivel: string;
  } | null>(null);

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

  if (resultado) {
    return (
      <main className="mx-auto max-w-2xl space-y-6 p-6">
        <div className="rounded-2xl border border-borde bg-white p-8 text-center shadow-sm">
          <div className="mb-4 text-5xl">🎉</div>

          <h1 className="mb-3 text-3xl font-extrabold">
            ¡Diagnóstico completado!
          </h1>

          <p className="mb-6 text-slate-600">
            Has terminado tu evaluación inicial.
          </p>

          <p className="text-lg font-bold">
            Respuestas correctas
          </p>

          <p className="my-3 text-5xl font-extrabold text-primario">
            {resultado.aciertos} / 6
          </p>

          <p className="mt-6 text-lg font-bold">
            Tu nivel inicial es:
          </p>

          <p className="my-4 text-3xl font-extrabold text-primario">
            {resultado.nivel}
          </p>

          <p className="mb-8 text-slate-600">
            Este resultado nos ayudará a conocer tu punto de partida.
            Por ahora, no cambia la dificultad de tus ejercicios.
          </p>

          <Link
            to={`/practicar/${temaId}`}
            className="inline-block rounded-xl bg-primario px-8 py-3 font-bold text-white"
          >
            Comenzar a practicar
          </Link>
        </div>
      </main>
    );
  }

  const respondidas = Object.keys(respuestas).length;

  async function entregarDiagnostico() {
    try {
      const resultado = await api.post<{
        completado: boolean;
        aciertos: number;
        nivel: string;
      }>(`/temas/${temaId}/diagnostico/entregar`, {
        respuestas: Object.entries(respuestas).map(
          ([ejercicioId, opcionId]) => ({
            ejercicio_id: Number(ejercicioId),
            opcion_id: opcionId,
          })
        ),
      });

      setResultado({
        aciertos: resultado.aciertos,
        nivel: resultado.nivel,
      });
    } catch (error) {
      alert(
        error instanceof Error
          ? error.message
          : "No se pudo entregar el diagnóstico"
      );
    }
  }

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
        onClick={entregarDiagnostico}
        disabled={respondidas !== 6}
        className="w-full rounded-xl bg-primario px-6 py-3 font-bold text-white disabled:cursor-not-allowed disabled:opacity-50"
      >
        Entregar diagnóstico
      </button>
    </main>
  );
}
