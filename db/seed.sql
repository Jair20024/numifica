INSERT INTO tema (nombre) VALUES ('Fracciones');

INSERT INTO ejercicio (tema_id, enunciado, dificultad, explicacion) VALUES
-- Dificultad 1
(1, '¿Cuánto es 1/4 + 2/4?', 1,
 'Con el mismo denominador se suman los numeradores: 1 + 2 = 3, y el denominador se mantiene: 3/4.'),
(1, '¿Cuál es la fracción más grande?', 1,
 'Mientras más grande es el denominador, más pequeñas son las partes. Por eso 1/2 es mayor que 1/3, 1/4 y 1/8.'),
(1, '¿Cuánto es 5/6 − 2/6?', 1,
 'Se restan los numeradores: 5 − 2 = 3, y el denominador se mantiene: 3/6.'),
(1, '¿Qué fracción es equivalente a 1/2?', 1,
 'Si multiplicas el numerador y el denominador por 2, obtienes 1/2 = 2/4.'),
-- Dificultad 2
(1, '¿Cuánto es 1/2 + 1/3?', 2,
 'El denominador común es 6: 1/2 = 3/6 y 1/3 = 2/6, entonces 3/6 + 2/6 = 5/6.'),
(1, '¿Cuánto es 3/4 − 1/2?', 2,
 '1/2 es igual a 2/4, entonces 3/4 − 2/4 = 1/4.'),
(1, 'Simplifica la fracción 6/8.', 2,
 'Divide el numerador y el denominador entre 2: 6/8 = 3/4.'),
(1, '¿Cuánto es 2/3 de 12?', 2,
 'Primero divide 12 entre 3, que da 4. Luego multiplica por 2: 4 × 2 = 8.'),
-- Dificultad 3
(1, '¿Cuánto es 3/4 + 1/2?', 3,
 '1/2 es igual a 2/4, y 3/4 + 2/4 = 5/4.'),
(1, '¿Cuánto es 2/3 + 3/4?', 3,
 'El denominador común es 12: 2/3 = 8/12 y 3/4 = 9/12, entonces 8/12 + 9/12 = 17/12.'),
(1, '¿Cuánto es 5/6 − 1/4?', 3,
 'El denominador común es 12: 5/6 = 10/12 y 1/4 = 3/12, entonces 10/12 − 3/12 = 7/12.'),
(1, 'Ana comió 1/4 de una pizza y Luis comió 2/8. ¿Qué fracción de la pizza comieron entre los dos?', 3,
 '1/4 es igual a 2/8, entonces 2/8 + 2/8 = 4/8, que se simplifica a 1/2.');

INSERT INTO opcion_ejercicio (ejercicio_id, texto, es_correcta)
SELECT e.id, o.texto, o.es_correcta
FROM ejercicio e
JOIN (VALUES
    ('¿Cuánto es 1/4 + 2/4?', '3/4', true),
    ('¿Cuánto es 1/4 + 2/4?', '3/8', false),
    ('¿Cuánto es 1/4 + 2/4?', '2/8', false),
    ('¿Cuánto es 1/4 + 2/4?', '1/2', false),

    ('¿Cuál es la fracción más grande?', '1/2', true),
    ('¿Cuál es la fracción más grande?', '1/3', false),
    ('¿Cuál es la fracción más grande?', '1/4', false),
    ('¿Cuál es la fracción más grande?', '1/8', false),

    ('¿Cuánto es 5/6 − 2/6?', '3/6', true),
    ('¿Cuánto es 5/6 − 2/6?', '7/6', false),
    ('¿Cuánto es 5/6 − 2/6?', '3/12', false),
    ('¿Cuánto es 5/6 − 2/6?', '2/6', false),

    ('¿Qué fracción es equivalente a 1/2?', '2/4', true),
    ('¿Qué fracción es equivalente a 1/2?', '1/4', false),
    ('¿Qué fracción es equivalente a 1/2?', '2/3', false),
    ('¿Qué fracción es equivalente a 1/2?', '3/4', false),

    ('¿Cuánto es 1/2 + 1/3?', '5/6', true),
    ('¿Cuánto es 1/2 + 1/3?', '2/5', false),
    ('¿Cuánto es 1/2 + 1/3?', '2/6', false),
    ('¿Cuánto es 1/2 + 1/3?', '1/5', false),

    ('¿Cuánto es 3/4 − 1/2?', '1/4', true),
    ('¿Cuánto es 3/4 − 1/2?', '2/2', false),
    ('¿Cuánto es 3/4 − 1/2?', '2/4', false),
    ('¿Cuánto es 3/4 − 1/2?', '1/2', false),

    ('Simplifica la fracción 6/8.', '3/4', true),
    ('Simplifica la fracción 6/8.', '3/8', false),
    ('Simplifica la fracción 6/8.', '6/4', false),
    ('Simplifica la fracción 6/8.', '2/4', false),

    ('¿Cuánto es 2/3 de 12?', '8', true),
    ('¿Cuánto es 2/3 de 12?', '6', false),
    ('¿Cuánto es 2/3 de 12?', '4', false),
    ('¿Cuánto es 2/3 de 12?', '10', false),

    ('¿Cuánto es 3/4 + 1/2?', '5/4', true),
    ('¿Cuánto es 3/4 + 1/2?', '4/6', false),
    ('¿Cuánto es 3/4 + 1/2?', '3/8', false),
    ('¿Cuánto es 3/4 + 1/2?', '1/4', false),

    ('¿Cuánto es 2/3 + 3/4?', '17/12', true),
    ('¿Cuánto es 2/3 + 3/4?', '5/7', false),
    ('¿Cuánto es 2/3 + 3/4?', '5/12', false),
    ('¿Cuánto es 2/3 + 3/4?', '6/12', false),

    ('¿Cuánto es 5/6 − 1/4?', '7/12', true),
    ('¿Cuánto es 5/6 − 1/4?', '4/2', false),
    ('¿Cuánto es 5/6 − 1/4?', '4/12', false),
    ('¿Cuánto es 5/6 − 1/4?', '5/12', false),

    ('Ana comió 1/4 de una pizza y Luis comió 2/8. ¿Qué fracción de la pizza comieron entre los dos?', '1/2', true),
    ('Ana comió 1/4 de una pizza y Luis comió 2/8. ¿Qué fracción de la pizza comieron entre los dos?', '3/8', false),
    ('Ana comió 1/4 de una pizza y Luis comió 2/8. ¿Qué fracción de la pizza comieron entre los dos?', '3/12', false),
    ('Ana comió 1/4 de una pizza y Luis comió 2/8. ¿Qué fracción de la pizza comieron entre los dos?', '2/16', false)
) AS o(enunciado, texto, es_correcta) ON o.enunciado = e.enunciado;