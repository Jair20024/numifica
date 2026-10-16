import { useQuery } from "@tanstack/react-query";
import { api } from "../api";
import type { FilaRanking } from "../api";

export default function Ranking() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["ranking"],
    queryFn: () => api.get<FilaRanking[]>("/ranking"),
  });

  return (
    <div>
      <h1 className="mb-5 text-3xl font-extrabold">Tabla de clasificación - 6to B</h1>

      {isLoading && <p>Cargando…</p>}
      {error && <p className="font-semibold text-error">{error.message}</p>}

      {data && (
        <div className="overflow-hidden rounded-2xl border border-borde bg-white">
          <table className="w-full text-left text-lg">
            <thead className="bg-cabecera">
              <tr>
                <th className="px-5 py-3">#</th>
                <th className="px-5 py-3">Alias</th>
                <th className="px-5 py-3">Rango</th>
                <th className="px-5 py-3 text-right">XP</th>
              </tr>
            </thead>
            <tbody>
              {data.map((f) => (
                <tr key={f.posicion} className={f.es_yo ? "bg-destacado font-extrabold" : ""}>
                  <td className="px-5 py-3">{f.posicion}</td>
                  <td className="px-5 py-3">
                    {f.alias}
                    {f.es_yo && " (tú)"}
                  </td>
                  <td className="px-5 py-3">{f.rango}</td>
                  <td className="px-5 py-3 text-right">{f.xp}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}