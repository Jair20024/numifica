import { NavLink, Outlet } from "react-router";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api";

const clase = ({ isActive }: { isActive: boolean }) =>
  "border-b-2 px-1 pb-1 font-bold " +
  (isActive ? "border-primario" : "border-transparent hover:border-borde");

export default function Layout() {
  const qc = useQueryClient();
  const salir = useMutation({
    mutationFn: () => api.post("/auth/logout"),
    onSettled: () => {
      // 1) Marcar "sin sesión": la ruta protegida redirige al login
      qc.setQueryData(["me"], null);
      // 2) Borrar los datos del usuario anterior (ranking, progreso...) menos la sesión
      qc.removeQueries({ predicate: (q) => q.queryKey[0] !== "me" });
    },
  });

  return (
    <div className="min-h-screen">
      <header className="border-b border-borde bg-white">
        <nav className="mx-auto flex max-w-3xl items-center justify-between px-6 py-3">
          <div className="flex gap-5">
            <NavLink to="/" end className={clase}>Inicio</NavLink>
            <NavLink to="/ranking" className={clase}>Ranking</NavLink>
          </div>
          <button onClick={() => salir.mutate()} className="font-bold hover:text-primario">
            Salir
          </button>
        </nav>
      </header>
      <main className="mx-auto max-w-3xl px-6 py-8">
        <Outlet />
      </main>
    </div>
  );
}