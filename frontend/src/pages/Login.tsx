import { useState } from "react";
import type { FormEvent } from "react";
import { Navigate } from "react-router";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api";
import type { Usuario } from "../api";
import { useUsuario } from "../auth";

export default function Login() {
  const qc = useQueryClient();
  const { data: usuario, isLoading } = useUsuario();
  const [user, setUser] = useState("");
  const [pass, setPass] = useState("");

  const login = useMutation({
    mutationFn: () =>
      api.post<Usuario>("/auth/login", { usuario: user.trim(), contrasena: pass }),
    onSuccess: (u) => qc.setQueryData(["me"], u),
  });

  if (isLoading) return null;
  if (usuario) return <Navigate to="/" replace />;

  function enviar(e: FormEvent) {
    e.preventDefault();
    login.mutate();
  }

  const campo =
    "mt-2 w-full rounded-xl border-2 border-borde bg-white px-4 py-3 text-lg " +
    "focus:border-primario focus:outline-none";

  return (
    <div className="flex min-h-screen items-center justify-center p-6">
      <form
        onSubmit={enviar}
        className="w-full max-w-md rounded-3xl border border-borde bg-white p-8 shadow-sm"
      >
        <h1 className="mb-6 text-center text-3xl font-extrabold">Matemática 6to B</h1>

        <label className="block font-bold">
          Usuario
          <input
            className={campo}
            value={user}
            onChange={(e) => setUser(e.target.value)}
            autoComplete="username"
            autoFocus
          />
        </label>

        <label className="mt-4 block font-bold">
          Contraseña
          <input
            className={campo}
            type="password"
            value={pass}
            onChange={(e) => setPass(e.target.value)}
            autoComplete="current-password"
          />
        </label>

        {login.error && (
          <p role="alert" className="mt-4 rounded-lg bg-red-50 px-4 py-2 font-semibold text-error">
            {login.error.message}
          </p>
        )}

        <button
          type="submit"
          disabled={login.isPending || !user.trim() || !pass}
          className="mt-6 w-full rounded-xl bg-primario py-3 text-lg font-extrabold text-white
                     hover:bg-primario-oscuro disabled:opacity-50"
        >
          {login.isPending ? "Ingresando…" : "Ingresar"}
        </button>
      </form>
    </div>
  );
}