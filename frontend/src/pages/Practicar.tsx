import { useRef, useState } from "react";
import { Link, useNavigate, useParams } from "react-router";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "../api";
import type { Ejercicio, Progreso, Resultado } from "../api";
import { nuevoToken } from "../util";

const TOTAL = 10;
const NOMBRE_TEMA = "Fracciones"; // temporal: en esta versión el tema es fijo

export default function Practicar() {
  const { temaId } = useParams();
  const [ronda, setRonda] = useState(0);

  const primero = useQuery({
    queryKey: ["primer-ejercicio", temaId, ronda],
    queryFn: () => api.get<Ejercicio>(`/temas/${temaId}/siguiente`),
    gcTime: 0,
    staleTime: Infinity,
  });

  if (primero.isLoading) {
    return <p className="p-8 text-center text-lg">Cargando…</p>;
  }

  if (primero.error || !primero.data) {
    return (
      <div className="mx-auto max-w-md p-8 text-center">
        <p role="alert" className="rounded-lg bg-red-50 px-4 py-3 font-semibold text-error">
          {primero.error?.message ?? "No se pudo cargar el ejercicio"}
        </p>
        <Link to="/" className="mt-4 inline-block font-bold text-primario underline">
          Volver al inicio
        </Link>
      </div>
    );
  }

  return (
    <Sesion key={ronda} primero={primero.data} onRepetir={() => setRonda((r) => r + 1)} />
  );
}

function Sesion({ primero, onRepetir }: { primero: Ejercicio; onRepetir: () => void }) {
  const qc = useQueryClient();
  const navigate = useNavigate();

  const { data: progreso } = useQuery({
    queryKey: ["progreso"],
    queryFn: () => api.get<Progreso>("/estudiantes/me/progreso"),
  });

  const [ejercicio, setEjercicio] = useState(primero);
  const [numero, setNumero] = useState(1);
  const [seleccion, setSeleccion] = useState<number | null>(null);
  const [resultado, setResultado] = useState<Resultado | null>(null);
  const [terminada, setTerminada] = useState(false);
  const [token, setToken] = useState(nuevoToken);
  const [xpTotal, setXpTotal] = useState<number | null>(null);
  const [aciertos, setAciertos] = useState(0);
  const [xpSesion, setXpSesion] = useState(0);
  const [rango, setRango] = useState("");
  const inicio = useRef(Date.now());

  const enviar = useMutation({
    mutationFn: () =>
      api.post<Resultado>("/intentos", {
        token_envio: token,
        ejercicio_id: ejercicio.id,
        opcion_id: seleccion,
        tiempo_seg: Math.min(3600, Math.round((Date.now() - inicio.current) / 1000)),
      }),
    onSuccess: (r) => {
      setResultado(r);
      setXpTotal(r.xp_total);
      setRango(r.rango);
      setXpSesion((x) => x + r.xp_ganado);
      if (r.es_correcto) setAciertos((a) => a + 1);
      qc.invalidateQueries({ queryKey: ["progreso"] });
      qc.invalidateQueries({ queryKey: ["ranking"] });
    },
  });

  function siguiente() {
    if (!resultado) return;
    if (numero >= TOTAL || !resultado.siguiente) {
      setTerminada(true);
      return;
    }
    setEjercicio(resultado.siguiente);
    setNumero((n) => n + 1);
    setSeleccion(null);
    setResultado(null);
    setToken(nuevoToken()); // token nuevo para el nuevo ejercicio
    enviar.reset();
    inicio.current = Date.now();
  }

  const completados = terminada ? TOTAL : numero - 1 + (resultado ? 1 : 0);
  const xpMostrado = xpTotal ?? progreso?.xp_total;

  return (
    <div className="min-h-screen">
      <header className="border-b border-borde bg-white">
        <div className="mx-auto grid max-w-3xl grid-cols-3 items-center px-6 py-3 font-bold">
          <span>{NOMBRE_TEMA}</span>
          <span className="text-center">
            {terminada ? "¡Listo!" : `Ejercicio ${numero} de ${TOTAL}`}
          </span>
          <span className="flex justify-end gap-4">
            {xpMostrado !== undefined && <span>XP: {xpMostrado}</span>}
            <button onClick={() => navigate("/")} className="hover:text-primario">
              Salir
            </button>
          </span>
        </div>
        <div
          className="h-1.5 bg-borde"
          role="progressbar"
          aria-label="Progreso de la práctica"
          aria-valuemin={0}
          aria-valuemax={TOTAL}
          aria-valuenow={completados}
        >
          <div
            className="h-full bg-primario transition-all duration-500"
            style={{ width: `${(completados / TOTAL) * 100}%` }}
          />
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-6 py-8">
        {terminada ? (
          <Resumen
            respondidos={numero}
            aciertos={aciertos}
            xpSesion={xpSesion}
            rango={rango}
            onRepetir={onRepetir}
          />
        ) : resultado ? (
          <Retroalimentacion
            r={resultado}
            esUltimo={numero >= TOTAL || !resultado.siguiente}
            onSiguiente={siguiente}
          />
        ) : (
          <div>
            <div className="rounded-2xl border border-borde bg-white p-6 text-2xl font-extrabold">
              {ejercicio.enunciado}
            </div>

            <fieldset disabled={enviar.isPending} className="mt-5">
              <legend className="sr-only">Elige una respuesta</legend>
              <div className="grid gap-4 sm:grid-cols-2">
                {ejercicio.opciones.map((o) => (
                  <label
                    key={o.id}
                    className="flex cursor-pointer items-center gap-3 rounded-2xl border-2 border-borde
                               bg-white px-5 py-4 text-xl font-bold hover:border-primario
                               has-checked:border-primario has-checked:bg-blue-50"
                  >
                    <input
                      type="radio"
                      name="opcion"
                      value={o.id}
                      checked={seleccion === o.id}
                      onChange={() => setSeleccion(o.id)}
                      className="size-5 accent-primario"
                    />
                    {o.texto}
                  </label>
                ))}
              </div>
            </fieldset>

            {enviar.error && (
              <p role="alert" className="mt-4 rounded-lg bg-red-50 px-4 py-2 font-semibold text-error">
                {enviar.error.message}. Pulsa Responder otra vez.
              </p>
            )}

            <div className="mt-6 text-center">
              <button
                onClick={() => enviar.mutate()}
                disabled={seleccion === null || enviar.isPending}
                className="rounded-xl bg-primario px-10 py-3 text-lg font-extrabold text-white
                           hover:bg-primario-oscuro disabled:opacity-50"
              >
                {enviar.isPending ? "Enviando…" : "Responder"}
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

// P-04: retroalimentación de acierto y de error
function Retroalimentacion({
  r,
  esUltimo,
  onSiguiente,
}: {
  r: Resultado;
  esUltimo: boolean;
  onSiguiente: () => void;
}) {
  const ok = r.es_correcto;
  return (
    <div
      role="status"
      className="mx-auto max-w-lg rounded-3xl border border-borde bg-white p-8 text-center shadow-sm"
    >
      <div
        className={`mx-auto flex size-16 items-center justify-center rounded-full text-white ${
          ok ? "bg-acierto" : "bg-error"
        }`}
      >
        {ok ? (
          <svg
            viewBox="0 0 24 24"
            className="size-9"
            fill="none"
            stroke="currentColor"
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden="true"
          >
            <path d="M5 12.5l4.5 4.5L19 7.5" />
          </svg>
        ) : (
          <span className="text-4xl font-extrabold" aria-hidden="true">!</span>
        )}
      </div>

      {ok ? (
        <>
          <h2 className="mt-4 text-3xl font-extrabold text-acierto">¡Muy bien!</h2>
          <p className="mt-2 text-2xl font-extrabold">+{r.xp_ganado} XP</p>
        </>
      ) : (
        <>
          <h2 className="mt-4 text-2xl font-extrabold text-error">
            No es correcto, ¡sigue intentando!
          </h2>
          <p className="mt-3 text-lg">
            <strong>Respuesta correcta:</strong> {r.respuesta_correcta}
          </p>
          <p className="mt-2 text-slate-600">Explicación: {r.explicacion}</p>
        </>
      )}

      <button
        onClick={onSiguiente}
        autoFocus
        className="mt-6 rounded-xl bg-primario px-8 py-3 text-lg font-extrabold text-white
                   hover:bg-primario-oscuro"
      >
        {esUltimo ? "Ver resumen" : "Siguiente"}
      </button>
    </div>
  );
}

// P-05: resumen de la práctica
function Resumen({
  respondidos,
  aciertos,
  xpSesion,
  rango,
  onRepetir,
}: {
  respondidos: number;
  aciertos: number;
  xpSesion: number;
  rango: string;
  onRepetir: () => void;
}) {
  return (
    <div className="mx-auto max-w-lg rounded-3xl border border-borde bg-white p-8 text-center shadow-sm">
      <h1 className="text-3xl font-extrabold">¡Terminaste la práctica!</h1>
      <p className="mt-4 text-xl">
        Acertaste <strong>{aciertos}</strong> de {respondidos}
      </p>
      <p className="mt-1 text-xl">
        Ganaste <strong>{xpSesion} XP</strong>
      </p>
      <p className="mt-1 text-slate-600">Tu rango: {rango}</p>

      <div className="mt-6 flex flex-wrap justify-center gap-3">
        <button
          onClick={onRepetir}
          className="rounded-xl bg-primario px-6 py-3 font-extrabold text-white hover:bg-primario-oscuro"
        >
          Practicar de nuevo
        </button>
        <Link
          to="/ranking"
          className="rounded-xl border-2 border-borde px-6 py-3 font-extrabold hover:border-primario"
        >
          Ver ranking
        </Link>
        <Link
          to="/"
          className="rounded-xl border-2 border-borde px-6 py-3 font-extrabold hover:border-primario"
        >
          Inicio
        </Link>
      </div>
    </div>
  );
}