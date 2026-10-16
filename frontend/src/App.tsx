import { BrowserRouter, Navigate, Outlet, Route, Routes } from "react-router";
import { useUsuario } from "./auth";
import Layout from "./components/Layout";
import Login from "./pages/Login";
import Inicio from "./pages/Inicio";
import Ranking from "./pages/Ranking";
import Practicar from "./pages/Practicar";

function RutaProtegida() {
  const { data: usuario, isLoading } = useUsuario();
  if (isLoading) return <p className="p-8 text-center">Cargando…</p>;
  if (!usuario) return <Navigate to="/login" replace />;
  return <Outlet />;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route element={<RutaProtegida />}>
          <Route element={<Layout />}>
            <Route path="/" element={<Inicio />} />
            <Route path="/ranking" element={<Ranking />} />
          </Route>
          <Route path="/practicar/:temaId" element={<Practicar />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}


