
BEGIN;

CREATE TABLE competencia (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

ALTER TABLE tema
ADD COLUMN competencia_id BIGINT
REFERENCES competencia(id);

INSERT INTO competencia (nombre) VALUES
('Resuelve problemas de cantidad'),
('Resuelve problemas de regularidad, equivalencia y cambio');

-- Asociar el tema antiguo con su competencia.
UPDATE tema
SET competencia_id = (
    SELECT id FROM competencia
    WHERE nombre = 'Resuelve problemas de cantidad'
)
WHERE nombre = 'Fracciones';

-- Actualizar el nombre anterior.
UPDATE tema
SET nombre = 'Fracciones y operaciones'
WHERE nombre = 'Fracciones';

-- Crear el segundo tema.
INSERT INTO tema (nombre, competencia_id)
SELECT 'Patrones y secuencias', id
FROM competencia
WHERE nombre = 'Resuelve problemas de regularidad, equivalencia y cambio';

-- Todos los temas deben pertenecer a una competencia.
ALTER TABLE tema
ALTER COLUMN competencia_id SET NOT NULL;

COMMIT;
