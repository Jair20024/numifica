
BEGIN;

-- Conservar los ejercicios anteriores,
-- pero retirarlos de las nuevas prácticas.
UPDATE ejercicio
SET activo = FALSE
WHERE tema_id = (
    SELECT id FROM tema
    WHERE nombre = 'Fracciones y operaciones'
);

-- Nuevos ejercicios.
WITH nuevos(tema, enunciado, dificultad, explicacion) AS (
    VALUES
    (
        'Fracciones y operaciones',
        'María tiene 20 caramelos y decide regalar las 3/4 partes. ¿Cuántos caramelos regala?',
        1,
        'Primero dividimos 20 entre 4 y obtenemos 5. Después multiplicamos 5 por 3. María regala 15 caramelos.'
    ),
    (
        'Fracciones y operaciones',
        'Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?',
        2,
        'Un tercio de 36 es 12. Por lo tanto, Luis conserva 36 - 12 = 24 canicas.'
    ),
    (
        'Fracciones y operaciones',
        'Ana gastó 2/5 de su dinero en un libro y 1/4 en un cuaderno. Si tenía 100 soles, ¿cuánto dinero le queda?',
        3,
        'Gastó 40 soles en el libro y 25 en el cuaderno. En total gastó 65 soles, por lo que le quedan 35.'
    ),
    (
        'Patrones y secuencias',
        'Una secuencia comienza con 3, 6, 9, 12. ¿Qué número continúa?',
        1,
        'Cada número aumenta en 3 unidades. Después de 12 continúa 15.'
    ),
    (
        'Patrones y secuencias',
        'En una secuencia, cada número es el doble del anterior: 2, 4, 8, 16. ¿Cuál es el sexto término?',
        2,
        'El quinto término es 32 y el sexto es 64.'
    ),
    (
        'Patrones y secuencias',
        'Una figura tiene 5 puntos en la etapa 1, 9 en la etapa 2 y 13 en la etapa 3. Si el patrón continúa, ¿cuántos puntos tendrá en la etapa 10?',
        3,
        'La secuencia aumenta de 4 en 4. La regla es 4n + 1. Para n = 10 obtenemos 41 puntos.'
    )
)
INSERT INTO ejercicio (
    tema_id, enunciado, dificultad, explicacion
)
SELECT t.id, n.enunciado, n.dificultad, n.explicacion
FROM nuevos n
JOIN tema t ON t.nombre = n.tema;

-- Opciones de respuesta.
WITH opciones(enunciado, texto, es_correcta) AS (
    VALUES
    ('María tiene 20 caramelos y decide regalar las 3/4 partes. ¿Cuántos caramelos regala?', '5 caramelos', FALSE),
    ('María tiene 20 caramelos y decide regalar las 3/4 partes. ¿Cuántos caramelos regala?', '10 caramelos', FALSE),
    ('María tiene 20 caramelos y decide regalar las 3/4 partes. ¿Cuántos caramelos regala?', '15 caramelos', TRUE),
    ('María tiene 20 caramelos y decide regalar las 3/4 partes. ¿Cuántos caramelos regala?', '18 caramelos', FALSE),

    ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '12 canicas', FALSE),
    ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '18 canicas', FALSE),
    ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '24 canicas', TRUE),
    ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '30 canicas', FALSE),

    ('Ana gastó 2/5 de su dinero en un libro y 1/4 en un cuaderno. Si tenía 100 soles, ¿cuánto dinero le queda?', '25 soles', FALSE),
    ('Ana gastó 2/5 de su dinero en un libro y 1/4 en un cuaderno. Si tenía 100 soles, ¿cuánto dinero le queda?', '35 soles', TRUE),
    ('Ana gastó 2/5 de su dinero en un libro y 1/4 en un cuaderno. Si tenía 100 soles, ¿cuánto dinero le queda?', '45 soles', FALSE),
    ('Ana gastó 2/5 de su dinero en un libro y 1/4 en un cuaderno. Si tenía 100 soles, ¿cuánto dinero le queda?', '65 soles', FALSE),

    ('Una secuencia comienza con 3, 6, 9, 12. ¿Qué número continúa?', '13', FALSE),
    ('Una secuencia comienza con 3, 6, 9, 12. ¿Qué número continúa?', '14', FALSE),
    ('Una secuencia comienza con 3, 6, 9, 12. ¿Qué número continúa?', '15', TRUE),
    ('Una secuencia comienza con 3, 6, 9, 12. ¿Qué número continúa?', '18', FALSE),

    ('En una secuencia, cada número es el doble del anterior: 2, 4, 8, 16. ¿Cuál es el sexto término?', '24', FALSE),
    ('En una secuencia, cada número es el doble del anterior: 2, 4, 8, 16. ¿Cuál es el sexto término?', '32', FALSE),
    ('En una secuencia, cada número es el doble del anterior: 2, 4, 8, 16. ¿Cuál es el sexto término?', '48', FALSE),
    ('En una secuencia, cada número es el doble del anterior: 2, 4, 8, 16. ¿Cuál es el sexto término?', '64', TRUE),

    ('Una figura tiene 5 puntos en la etapa 1, 9 en la etapa 2 y 13 en la etapa 3. Si el patrón continúa, ¿cuántos puntos tendrá en la etapa 10?', '37 puntos', FALSE),
    ('Una figura tiene 5 puntos en la etapa 1, 9 en la etapa 2 y 13 en la etapa 3. Si el patrón continúa, ¿cuántos puntos tendrá en la etapa 10?', '40 puntos', FALSE),
    ('Una figura tiene 5 puntos en la etapa 1, 9 en la etapa 2 y 13 en la etapa 3. Si el patrón continúa, ¿cuántos puntos tendrá en la etapa 10?', '41 puntos', TRUE),
    ('Una figura tiene 5 puntos en la etapa 1, 9 en la etapa 2 y 13 en la etapa 3. Si el patrón continúa, ¿cuántos puntos tendrá en la etapa 10?', '45 puntos', FALSE)
)
INSERT INTO opcion_ejercicio (
    ejercicio_id, texto, es_correcta
)
SELECT e.id, o.texto, o.es_correcta
FROM opciones o
JOIN ejercicio e ON e.enunciado = o.enunciado;

COMMIT;
