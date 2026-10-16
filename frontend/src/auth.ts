import { useQuery } from "@tanstack/react-query";
import { api, ApiError } from "./api";
import type { Usuario } from "./api";

export function useUsuario() {
  return useQuery({
    queryKey: ["me"],
    queryFn: async (): Promise<Usuario | null> => {
      try {
        return await api.get<Usuario>("/auth/me");
      } catch (e) {
        if (e instanceof ApiError && e.status === 401) return null;
        throw e;
      }
    },
    staleTime: Infinity,
  });
}