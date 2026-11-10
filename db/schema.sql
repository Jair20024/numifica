CREATE TABLE usuario (
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario           VARCHAR(50)  NOT NULL UNIQUE,
    contrasena_hash   VARCHAR(255) NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    alias             VARCHAR(30),
    rol               VARCHAR(15)  NOT NULL
        CHECK (rol IN ('ESTUDIANTE', 'PROFESOR', 'PADRE', 'ADMINISTRADOR')),
    xp_total          INTEGER      NOT NULL DEFAULT 0 CHECK (xp_total >= 0),
    xp_actualizado_en TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE sesion_auth (
    token             VARCHAR(64) PRIMARY KEY,
    usuario_id        BIGINT      NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    creada_en         TIMESTAMPTZ NOT NULL DEFAULT now(),
    ultima_actividad  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tema (
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre  VARCHAR(150) NOT NULL
);

CREATE TABLE ejercicio (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tema_id      BIGINT   NOT NULL REFERENCES tema(id),
    enunciado    TEXT     NOT NULL UNIQUE,
    dificultad   SMALLINT NOT NULL CHECK (dificultad BETWEEN 1 AND 3),
    explicacion  TEXT     NOT NULL,
    activo       BOOLEAN  NOT NULL DEFAULT TRUE
);

CREATE TABLE opcion_ejercicio (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ejercicio_id  BIGINT       NOT NULL REFERENCES ejercicio(id) ON DELETE CASCADE,
    texto         VARCHAR(255) NOT NULL,
    es_correcta   BOOLEAN      NOT NULL
);

-- Solo una opción correcta por ejercicio
CREATE UNIQUE INDEX uq_una_correcta_por_ejercicio
    ON opcion_ejercicio (ejercicio_id) WHERE es_correcta;

CREATE TABLE intento (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    token_envio    UUID        NOT NULL UNIQUE,
    estudiante_id  BIGINT      NOT NULL REFERENCES usuario(id),
    ejercicio_id   BIGINT      NOT NULL REFERENCES ejercicio(id),
    opcion_id      BIGINT      NOT NULL REFERENCES opcion_ejercicio(id),
    es_correcto    BOOLEAN     NOT NULL,
    tiempo_seg     INTEGER     NOT NULL CHECK (tiempo_seg >= 0),
    xp_ganado      INTEGER     NOT NULL DEFAULT 0 CHECK (xp_ganado >= 0),
    fecha_hora     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ix_intento_estudiante ON intento (estudiante_id, fecha_hora DESC);