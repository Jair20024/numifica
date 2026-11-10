-- Banco inicial de Numifica: 30 ejercicios contextualizados.
-- Compatible con db/schema.sql actualizado y con la base ya migrada.
-- Puede ejecutarse de nuevo: no duplica ejercicios ni alternativas.
BEGIN;

INSERT INTO competencia (nombre) VALUES
  ('Resuelve problemas de cantidad'),
  ('Resuelve problemas de regularidad, equivalencia y cambio')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO tema (nombre, competencia_id)
SELECT datos.tema, c.id
FROM (VALUES
  ('Fracciones y operaciones', 'Resuelve problemas de cantidad'),
  ('Patrones y secuencias', 'Resuelve problemas de regularidad, equivalencia y cambio')
) AS datos(tema, competencia)
JOIN competencia c ON c.nombre = datos.competencia
ON CONFLICT (nombre) DO UPDATE SET competencia_id = EXCLUDED.competencia_id;

WITH datos(tema, enunciado, dificultad, explicacion) AS (
 VALUES
  ('Fracciones y operaciones', 'María tiene 20 caramelos y regala las 3/4 partes. ¿Cuántos caramelos regala?', 1, '20 ÷ 4 = 5; 5 × 3 = 15.'),
  ('Fracciones y operaciones', 'Pedro tiene 18 lápices y presta 1/3 de ellos. ¿Cuántos lápices presta?', 1, '18 ÷ 3 = 6.'),
  ('Fracciones y operaciones', 'Rosa reparte 24 galletas y entrega 1/4 a su prima. ¿Cuántas galletas entrega?', 1, '24 ÷ 4 = 6.'),
  ('Fracciones y operaciones', 'En una caja hay 30 pelotas. Si 1/5 son azules, ¿cuántas pelotas azules hay?', 1, '30 ÷ 5 = 6.'),
  ('Fracciones y operaciones', 'Julia bebió 2/8 de un litro de jugo. ¿Qué fracción equivalente representa lo que bebió?', 1, 'Simplificar 2/8 dividiendo numerador y denominador entre 2 da 1/4.'),
  ('Fracciones y operaciones', 'Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', 2, '36 ÷ 3 = 12 entregadas; 36 − 12 = 24.'),
  ('Fracciones y operaciones', 'Un salón tiene 40 estudiantes. Si 3/5 participan en un concurso, ¿cuántos participan?', 2, '40 ÷ 5 × 3 = 24.'),
  ('Fracciones y operaciones', 'Carla tenía 48 stickers y regaló 3/8. ¿Cuántos stickers le quedaron?', 2, '3/8 de 48 es 18; 48 − 18 = 30.'),
  ('Fracciones y operaciones', 'Una receta usa 1/2 taza de avena y 1/4 taza de quinua. ¿Cuánto se usa en total?', 2, '1/2 equivale a 2/4; 2/4 + 1/4 = 3/4.'),
  ('Fracciones y operaciones', 'De una cinta de 2 metros, Elena corta 3/4 de metro. ¿Cuánta cinta queda?', 2, '2 − 3/4 = 8/4 − 3/4 = 5/4 = 1 1/4.'),
  ('Fracciones y operaciones', 'Ana gastó 2/5 de 100 soles en un libro y 1/4 de los mismos 100 soles en un cuaderno. ¿Cuánto le queda?', 3, 'Gastó 40 + 25 = 65 soles; 100 − 65 = 35.'),
  ('Fracciones y operaciones', 'Sofía tenía 60 fichas. Regaló 1/3 y luego 1/4 de las fichas restantes. ¿Cuántas conserva?', 3, 'Regaló 20, quedaron 40; regaló 10 más y conserva 30.'),
  ('Fracciones y operaciones', 'Una familia recorrió 2/5 de una ruta el lunes y 1/3 el martes. ¿Qué fracción de la ruta falta recorrer?', 3, '2/5 + 1/3 = 6/15 + 5/15 = 11/15; falta 4/15.'),
  ('Fracciones y operaciones', 'Miguel usó 3/8 de un rollo de tela y luego 1/4 del rollo completo. Si el rollo medía 32 metros, ¿cuántos metros quedan?', 3, '3/8 de 32 = 12 y 1/4 de 32 = 8; quedan 32 − 20 = 12.'),
  ('Fracciones y operaciones', 'Después de regalar 2/5 de sus 50 tarjetas, Diego entrega la mitad de las que le quedan. ¿Cuántas tarjetas conserva?', 3, '2/5 de 50 = 20; quedan 30 y la mitad de 30 es 15.'),
  ('Patrones y secuencias', 'En una fila de números aparecen 3, 6, 9, 12. ¿Cuál sigue?', 1, 'Cada término aumenta en 3.'),
  ('Patrones y secuencias', 'Un niño coloca 2, 4, 6, 8 bloques en cuatro filas. ¿Cuántos bloques tendrá la quinta fila?', 1, 'El patrón aumenta de 2 en 2.'),
  ('Patrones y secuencias', 'Una secuencia de casilleros tiene los números 5, 10, 15, 20. ¿Qué número va después?', 1, 'El patrón suma 5 en cada paso.'),
  ('Patrones y secuencias', 'En un juego los puntajes son 20, 18, 16, 14. ¿Cuál será el siguiente puntaje?', 1, 'Cada término disminuye en 2.'),
  ('Patrones y secuencias', 'En una tabla se muestran 1, 3, 5, 7. ¿Qué número ocupa la siguiente posición?', 1, 'Se suman 2 unidades en cada término.'),
  ('Patrones y secuencias', 'Una secuencia duplica cada número: 2, 4, 8, 16. ¿Cuál es el sexto término?', 2, 'El quinto término es 32 y el sexto es 64.'),
  ('Patrones y secuencias', 'Una biblioteca coloca 4 libros en el primer estante, 7 en el segundo y 10 en el tercero. ¿Cuántos coloca en el sexto si continúa el patrón?', 2, 'El patrón aumenta de 3 en 3: 4, 7, 10, 13, 16, 19.'),
  ('Patrones y secuencias', 'En un reto los puntos siguen 3, 6, 12, 24. ¿Cuántos puntos corresponden al quinto turno?', 2, 'Cada término se multiplica por 2.'),
  ('Patrones y secuencias', 'En una secuencia, el primer número es 7 y se suman 4 unidades en cada paso. ¿Cuál es el quinto número?', 2, 'Los cinco términos son 7, 11, 15, 19 y 23.'),
  ('Patrones y secuencias', 'Una tienda organiza paquetes con 6, 11, 16 y 21 productos. ¿Cuántos tendrá el sexto paquete si sigue el patrón?', 2, 'Se suman 5 unidades: el quinto tiene 26 y el sexto 31.'),
  ('Patrones y secuencias', 'Una secuencia tiene 5 puntos en la etapa 1, 9 en la 2 y 13 en la 3. ¿Cuántos puntos habrá en la etapa 10?', 3, 'La regla es 4n + 1; para n = 10, da 41.'),
  ('Patrones y secuencias', 'Una secuencia empieza en 2 y cada término se obtiene multiplicando el anterior por 3. ¿Cuál es el quinto término?', 3, 'Los términos son 2, 6, 18, 54, 162.'),
  ('Patrones y secuencias', 'En una secuencia, el término de la posición n es 3n + 2. ¿Qué valor corresponde a la posición 12?', 3, '3 × 12 + 2 = 38.'),
  ('Patrones y secuencias', 'Una secuencia comienza 50, 45, 40, 35. ¿Qué número estará en la posición 9?', 3, 'La regla es 50 − 5(n − 1); en la posición 9: 50 − 40 = 10.'),
  ('Patrones y secuencias', 'Una figura se construye con 4 palitos en la etapa 1, 7 en la 2 y 10 en la 3. ¿Cuántos palitos tendrá la etapa 15?', 3, 'Se suman 3 palitos por etapa: 4 + 3 × 14 = 46.')
)
INSERT INTO ejercicio (tema_id, enunciado, dificultad, explicacion, activo)
SELECT t.id, d.enunciado, d.dificultad, d.explicacion, TRUE
FROM datos d JOIN tema t ON t.nombre = d.tema
ON CONFLICT (enunciado) DO UPDATE
SET tema_id = EXCLUDED.tema_id,
    dificultad = EXCLUDED.dificultad,
    explicacion = EXCLUDED.explicacion,
    activo = TRUE;

WITH datos(enunciado, texto, es_correcta) AS (
 VALUES
  ('María tiene 20 caramelos y regala las 3/4 partes. ¿Cuántos caramelos regala?', '15 caramelos', TRUE),
  ('María tiene 20 caramelos y regala las 3/4 partes. ¿Cuántos caramelos regala?', '5 caramelos', FALSE),
  ('María tiene 20 caramelos y regala las 3/4 partes. ¿Cuántos caramelos regala?', '10 caramelos', FALSE),
  ('María tiene 20 caramelos y regala las 3/4 partes. ¿Cuántos caramelos regala?', '18 caramelos', FALSE),
  ('Pedro tiene 18 lápices y presta 1/3 de ellos. ¿Cuántos lápices presta?', '6 lápices', TRUE),
  ('Pedro tiene 18 lápices y presta 1/3 de ellos. ¿Cuántos lápices presta?', '3 lápices', FALSE),
  ('Pedro tiene 18 lápices y presta 1/3 de ellos. ¿Cuántos lápices presta?', '9 lápices', FALSE),
  ('Pedro tiene 18 lápices y presta 1/3 de ellos. ¿Cuántos lápices presta?', '12 lápices', FALSE),
  ('Rosa reparte 24 galletas y entrega 1/4 a su prima. ¿Cuántas galletas entrega?', '6 galletas', TRUE),
  ('Rosa reparte 24 galletas y entrega 1/4 a su prima. ¿Cuántas galletas entrega?', '4 galletas', FALSE),
  ('Rosa reparte 24 galletas y entrega 1/4 a su prima. ¿Cuántas galletas entrega?', '8 galletas', FALSE),
  ('Rosa reparte 24 galletas y entrega 1/4 a su prima. ¿Cuántas galletas entrega?', '12 galletas', FALSE),
  ('En una caja hay 30 pelotas. Si 1/5 son azules, ¿cuántas pelotas azules hay?', '6 pelotas', TRUE),
  ('En una caja hay 30 pelotas. Si 1/5 son azules, ¿cuántas pelotas azules hay?', '5 pelotas', FALSE),
  ('En una caja hay 30 pelotas. Si 1/5 son azules, ¿cuántas pelotas azules hay?', '10 pelotas', FALSE),
  ('En una caja hay 30 pelotas. Si 1/5 son azules, ¿cuántas pelotas azules hay?', '15 pelotas', FALSE),
  ('Julia bebió 2/8 de un litro de jugo. ¿Qué fracción equivalente representa lo que bebió?', '1/4', TRUE),
  ('Julia bebió 2/8 de un litro de jugo. ¿Qué fracción equivalente representa lo que bebió?', '1/2', FALSE),
  ('Julia bebió 2/8 de un litro de jugo. ¿Qué fracción equivalente representa lo que bebió?', '2/4', FALSE),
  ('Julia bebió 2/8 de un litro de jugo. ¿Qué fracción equivalente representa lo que bebió?', '1/8', FALSE),
  ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '24 canicas', TRUE),
  ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '12 canicas', FALSE),
  ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '18 canicas', FALSE),
  ('Luis tiene 36 canicas y entrega 1/3 a su hermano. ¿Cuántas canicas conserva?', '30 canicas', FALSE),
  ('Un salón tiene 40 estudiantes. Si 3/5 participan en un concurso, ¿cuántos participan?', '24 estudiantes', TRUE),
  ('Un salón tiene 40 estudiantes. Si 3/5 participan en un concurso, ¿cuántos participan?', '8 estudiantes', FALSE),
  ('Un salón tiene 40 estudiantes. Si 3/5 participan en un concurso, ¿cuántos participan?', '16 estudiantes', FALSE),
  ('Un salón tiene 40 estudiantes. Si 3/5 participan en un concurso, ¿cuántos participan?', '30 estudiantes', FALSE),
  ('Carla tenía 48 stickers y regaló 3/8. ¿Cuántos stickers le quedaron?', '30 stickers', TRUE),
  ('Carla tenía 48 stickers y regaló 3/8. ¿Cuántos stickers le quedaron?', '18 stickers', FALSE),
  ('Carla tenía 48 stickers y regaló 3/8. ¿Cuántos stickers le quedaron?', '24 stickers', FALSE),
  ('Carla tenía 48 stickers y regaló 3/8. ¿Cuántos stickers le quedaron?', '36 stickers', FALSE),
  ('Una receta usa 1/2 taza de avena y 1/4 taza de quinua. ¿Cuánto se usa en total?', '3/4 de taza', TRUE),
  ('Una receta usa 1/2 taza de avena y 1/4 taza de quinua. ¿Cuánto se usa en total?', '2/6 de taza', FALSE),
  ('Una receta usa 1/2 taza de avena y 1/4 taza de quinua. ¿Cuánto se usa en total?', '1/4 de taza', FALSE),
  ('Una receta usa 1/2 taza de avena y 1/4 taza de quinua. ¿Cuánto se usa en total?', '1 taza', FALSE),
  ('De una cinta de 2 metros, Elena corta 3/4 de metro. ¿Cuánta cinta queda?', '1 1/4 metros', TRUE),
  ('De una cinta de 2 metros, Elena corta 3/4 de metro. ¿Cuánta cinta queda?', '1/4 de metro', FALSE),
  ('De una cinta de 2 metros, Elena corta 3/4 de metro. ¿Cuánta cinta queda?', '1 3/4 metros', FALSE),
  ('De una cinta de 2 metros, Elena corta 3/4 de metro. ¿Cuánta cinta queda?', '2 3/4 metros', FALSE),
  ('Ana gastó 2/5 de 100 soles en un libro y 1/4 de los mismos 100 soles en un cuaderno. ¿Cuánto le queda?', '35 soles', TRUE),
  ('Ana gastó 2/5 de 100 soles en un libro y 1/4 de los mismos 100 soles en un cuaderno. ¿Cuánto le queda?', '25 soles', FALSE),
  ('Ana gastó 2/5 de 100 soles en un libro y 1/4 de los mismos 100 soles en un cuaderno. ¿Cuánto le queda?', '45 soles', FALSE),
  ('Ana gastó 2/5 de 100 soles en un libro y 1/4 de los mismos 100 soles en un cuaderno. ¿Cuánto le queda?', '65 soles', FALSE),
  ('Sofía tenía 60 fichas. Regaló 1/3 y luego 1/4 de las fichas restantes. ¿Cuántas conserva?', '30 fichas', TRUE),
  ('Sofía tenía 60 fichas. Regaló 1/3 y luego 1/4 de las fichas restantes. ¿Cuántas conserva?', '25 fichas', FALSE),
  ('Sofía tenía 60 fichas. Regaló 1/3 y luego 1/4 de las fichas restantes. ¿Cuántas conserva?', '35 fichas', FALSE),
  ('Sofía tenía 60 fichas. Regaló 1/3 y luego 1/4 de las fichas restantes. ¿Cuántas conserva?', '40 fichas', FALSE),
  ('Una familia recorrió 2/5 de una ruta el lunes y 1/3 el martes. ¿Qué fracción de la ruta falta recorrer?', '4/15', TRUE),
  ('Una familia recorrió 2/5 de una ruta el lunes y 1/3 el martes. ¿Qué fracción de la ruta falta recorrer?', '1/15', FALSE),
  ('Una familia recorrió 2/5 de una ruta el lunes y 1/3 el martes. ¿Qué fracción de la ruta falta recorrer?', '7/15', FALSE),
  ('Una familia recorrió 2/5 de una ruta el lunes y 1/3 el martes. ¿Qué fracción de la ruta falta recorrer?', '11/15', FALSE),
  ('Miguel usó 3/8 de un rollo de tela y luego 1/4 del rollo completo. Si el rollo medía 32 metros, ¿cuántos metros quedan?', '12 metros', TRUE),
  ('Miguel usó 3/8 de un rollo de tela y luego 1/4 del rollo completo. Si el rollo medía 32 metros, ¿cuántos metros quedan?', '8 metros', FALSE),
  ('Miguel usó 3/8 de un rollo de tela y luego 1/4 del rollo completo. Si el rollo medía 32 metros, ¿cuántos metros quedan?', '16 metros', FALSE),
  ('Miguel usó 3/8 de un rollo de tela y luego 1/4 del rollo completo. Si el rollo medía 32 metros, ¿cuántos metros quedan?', '20 metros', FALSE),
  ('Después de regalar 2/5 de sus 50 tarjetas, Diego entrega la mitad de las que le quedan. ¿Cuántas tarjetas conserva?', '15 tarjetas', TRUE),
  ('Después de regalar 2/5 de sus 50 tarjetas, Diego entrega la mitad de las que le quedan. ¿Cuántas tarjetas conserva?', '10 tarjetas', FALSE),
  ('Después de regalar 2/5 de sus 50 tarjetas, Diego entrega la mitad de las que le quedan. ¿Cuántas tarjetas conserva?', '20 tarjetas', FALSE),
  ('Después de regalar 2/5 de sus 50 tarjetas, Diego entrega la mitad de las que le quedan. ¿Cuántas tarjetas conserva?', '25 tarjetas', FALSE),
  ('En una fila de números aparecen 3, 6, 9, 12. ¿Cuál sigue?', '15', TRUE),
  ('En una fila de números aparecen 3, 6, 9, 12. ¿Cuál sigue?', '13', FALSE),
  ('En una fila de números aparecen 3, 6, 9, 12. ¿Cuál sigue?', '14', FALSE),
  ('En una fila de números aparecen 3, 6, 9, 12. ¿Cuál sigue?', '18', FALSE),
  ('Un niño coloca 2, 4, 6, 8 bloques en cuatro filas. ¿Cuántos bloques tendrá la quinta fila?', '10 bloques', TRUE),
  ('Un niño coloca 2, 4, 6, 8 bloques en cuatro filas. ¿Cuántos bloques tendrá la quinta fila?', '9 bloques', FALSE),
  ('Un niño coloca 2, 4, 6, 8 bloques en cuatro filas. ¿Cuántos bloques tendrá la quinta fila?', '12 bloques', FALSE),
  ('Un niño coloca 2, 4, 6, 8 bloques en cuatro filas. ¿Cuántos bloques tendrá la quinta fila?', '16 bloques', FALSE),
  ('Una secuencia de casilleros tiene los números 5, 10, 15, 20. ¿Qué número va después?', '25', TRUE),
  ('Una secuencia de casilleros tiene los números 5, 10, 15, 20. ¿Qué número va después?', '21', FALSE),
  ('Una secuencia de casilleros tiene los números 5, 10, 15, 20. ¿Qué número va después?', '24', FALSE),
  ('Una secuencia de casilleros tiene los números 5, 10, 15, 20. ¿Qué número va después?', '30', FALSE),
  ('En un juego los puntajes son 20, 18, 16, 14. ¿Cuál será el siguiente puntaje?', '12', TRUE),
  ('En un juego los puntajes son 20, 18, 16, 14. ¿Cuál será el siguiente puntaje?', '10', FALSE),
  ('En un juego los puntajes son 20, 18, 16, 14. ¿Cuál será el siguiente puntaje?', '13', FALSE),
  ('En un juego los puntajes son 20, 18, 16, 14. ¿Cuál será el siguiente puntaje?', '16', FALSE),
  ('En una tabla se muestran 1, 3, 5, 7. ¿Qué número ocupa la siguiente posición?', '9', TRUE),
  ('En una tabla se muestran 1, 3, 5, 7. ¿Qué número ocupa la siguiente posición?', '8', FALSE),
  ('En una tabla se muestran 1, 3, 5, 7. ¿Qué número ocupa la siguiente posición?', '10', FALSE),
  ('En una tabla se muestran 1, 3, 5, 7. ¿Qué número ocupa la siguiente posición?', '11', FALSE),
  ('Una secuencia duplica cada número: 2, 4, 8, 16. ¿Cuál es el sexto término?', '64', TRUE),
  ('Una secuencia duplica cada número: 2, 4, 8, 16. ¿Cuál es el sexto término?', '24', FALSE),
  ('Una secuencia duplica cada número: 2, 4, 8, 16. ¿Cuál es el sexto término?', '32', FALSE),
  ('Una secuencia duplica cada número: 2, 4, 8, 16. ¿Cuál es el sexto término?', '48', FALSE),
  ('Una biblioteca coloca 4 libros en el primer estante, 7 en el segundo y 10 en el tercero. ¿Cuántos coloca en el sexto si continúa el patrón?', '19 libros', TRUE),
  ('Una biblioteca coloca 4 libros en el primer estante, 7 en el segundo y 10 en el tercero. ¿Cuántos coloca en el sexto si continúa el patrón?', '16 libros', FALSE),
  ('Una biblioteca coloca 4 libros en el primer estante, 7 en el segundo y 10 en el tercero. ¿Cuántos coloca en el sexto si continúa el patrón?', '18 libros', FALSE),
  ('Una biblioteca coloca 4 libros en el primer estante, 7 en el segundo y 10 en el tercero. ¿Cuántos coloca en el sexto si continúa el patrón?', '22 libros', FALSE),
  ('En un reto los puntos siguen 3, 6, 12, 24. ¿Cuántos puntos corresponden al quinto turno?', '48 puntos', TRUE),
  ('En un reto los puntos siguen 3, 6, 12, 24. ¿Cuántos puntos corresponden al quinto turno?', '30 puntos', FALSE),
  ('En un reto los puntos siguen 3, 6, 12, 24. ¿Cuántos puntos corresponden al quinto turno?', '36 puntos', FALSE),
  ('En un reto los puntos siguen 3, 6, 12, 24. ¿Cuántos puntos corresponden al quinto turno?', '42 puntos', FALSE),
  ('En una secuencia, el primer número es 7 y se suman 4 unidades en cada paso. ¿Cuál es el quinto número?', '23', TRUE),
  ('En una secuencia, el primer número es 7 y se suman 4 unidades en cada paso. ¿Cuál es el quinto número?', '19', FALSE),
  ('En una secuencia, el primer número es 7 y se suman 4 unidades en cada paso. ¿Cuál es el quinto número?', '24', FALSE),
  ('En una secuencia, el primer número es 7 y se suman 4 unidades en cada paso. ¿Cuál es el quinto número?', '27', FALSE),
  ('Una tienda organiza paquetes con 6, 11, 16 y 21 productos. ¿Cuántos tendrá el sexto paquete si sigue el patrón?', '31 productos', TRUE),
  ('Una tienda organiza paquetes con 6, 11, 16 y 21 productos. ¿Cuántos tendrá el sexto paquete si sigue el patrón?', '26 productos', FALSE),
  ('Una tienda organiza paquetes con 6, 11, 16 y 21 productos. ¿Cuántos tendrá el sexto paquete si sigue el patrón?', '30 productos', FALSE),
  ('Una tienda organiza paquetes con 6, 11, 16 y 21 productos. ¿Cuántos tendrá el sexto paquete si sigue el patrón?', '36 productos', FALSE),
  ('Una secuencia tiene 5 puntos en la etapa 1, 9 en la 2 y 13 en la 3. ¿Cuántos puntos habrá en la etapa 10?', '41 puntos', TRUE),
  ('Una secuencia tiene 5 puntos en la etapa 1, 9 en la 2 y 13 en la 3. ¿Cuántos puntos habrá en la etapa 10?', '37 puntos', FALSE),
  ('Una secuencia tiene 5 puntos en la etapa 1, 9 en la 2 y 13 en la 3. ¿Cuántos puntos habrá en la etapa 10?', '40 puntos', FALSE),
  ('Una secuencia tiene 5 puntos en la etapa 1, 9 en la 2 y 13 en la 3. ¿Cuántos puntos habrá en la etapa 10?', '45 puntos', FALSE),
  ('Una secuencia empieza en 2 y cada término se obtiene multiplicando el anterior por 3. ¿Cuál es el quinto término?', '162', TRUE),
  ('Una secuencia empieza en 2 y cada término se obtiene multiplicando el anterior por 3. ¿Cuál es el quinto término?', '54', FALSE),
  ('Una secuencia empieza en 2 y cada término se obtiene multiplicando el anterior por 3. ¿Cuál es el quinto término?', '81', FALSE),
  ('Una secuencia empieza en 2 y cada término se obtiene multiplicando el anterior por 3. ¿Cuál es el quinto término?', '243', FALSE),
  ('En una secuencia, el término de la posición n es 3n + 2. ¿Qué valor corresponde a la posición 12?', '38', TRUE),
  ('En una secuencia, el término de la posición n es 3n + 2. ¿Qué valor corresponde a la posición 12?', '36', FALSE),
  ('En una secuencia, el término de la posición n es 3n + 2. ¿Qué valor corresponde a la posición 12?', '39', FALSE),
  ('En una secuencia, el término de la posición n es 3n + 2. ¿Qué valor corresponde a la posición 12?', '42', FALSE),
  ('Una secuencia comienza 50, 45, 40, 35. ¿Qué número estará en la posición 9?', '10', TRUE),
  ('Una secuencia comienza 50, 45, 40, 35. ¿Qué número estará en la posición 9?', '5', FALSE),
  ('Una secuencia comienza 50, 45, 40, 35. ¿Qué número estará en la posición 9?', '15', FALSE),
  ('Una secuencia comienza 50, 45, 40, 35. ¿Qué número estará en la posición 9?', '20', FALSE),
  ('Una figura se construye con 4 palitos en la etapa 1, 7 en la 2 y 10 en la 3. ¿Cuántos palitos tendrá la etapa 15?', '46 palitos', TRUE),
  ('Una figura se construye con 4 palitos en la etapa 1, 7 en la 2 y 10 en la 3. ¿Cuántos palitos tendrá la etapa 15?', '43 palitos', FALSE),
  ('Una figura se construye con 4 palitos en la etapa 1, 7 en la 2 y 10 en la 3. ¿Cuántos palitos tendrá la etapa 15?', '45 palitos', FALSE),
  ('Una figura se construye con 4 palitos en la etapa 1, 7 en la 2 y 10 en la 3. ¿Cuántos palitos tendrá la etapa 15?', '49 palitos', FALSE)
)
INSERT INTO opcion_ejercicio (ejercicio_id, texto, es_correcta)
SELECT e.id, d.texto, d.es_correcta
FROM datos d JOIN ejercicio e ON e.enunciado = d.enunciado
WHERE NOT EXISTS (
  SELECT 1 FROM opcion_ejercicio o
  WHERE o.ejercicio_id = e.id AND o.texto = d.texto
);

COMMIT;