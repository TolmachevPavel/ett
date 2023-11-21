\echo -- 8. Параллельная обработка временных таблиц
-- 8. Параллельная обработка временных таблиц
\echo -- Создадим две таблицы, одну временную, другую обычную
-- Создадим две таблицы, одну временную, другую обычную

\echo CREATE TEMP TABLE t_temp8 (id integer);
CREATE TEMP TABLE t_temp8 (id integer);
\echo CREATE TABLE temp8 (id integer);
CREATE TABLE temp8 (id integer);

\echo -- Добавим туда по миллиону строк
-- Добавим туда по миллиону строк
\echo INSERT INTO t_temp8 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO t_temp8 SELECT * FROM generate_series(1,1_000_000);
\echo INSERT INTO temp8 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO temp8 SELECT * FROM generate_series(1,1_000_000);

\echo -- Руками сделаем анализ
-- Руками сделаем анализ
\echo ANALYZE t_temp8;
ANALYZE t_temp8;
\echo ANALYZE temp8;
ANALYZE temp8;

\echo -- Посмотрим план запросов
-- Посмотрим план запросов
\echo EXPLAIN ANALYZE SELECT * FROM t_temp8;
EXPLAIN ANALYZE SELECT * FROM t_temp8;
\echo EXPLAIN ANALYZE SELECT * FROM temp8;
EXPLAIN ANALYZE SELECT * FROM temp8;

\echo -- Установим пар-р, с помощью которого можно посмотреть параллельный план
-- Установим пар-р, с помощью которого можно посмотреть параллельный план
\echo SHOW debug_parallel_query;
SHOW debug_parallel_query;
\echo SET debug_parallel_query = on;
SET debug_parallel_query = on;

\echo -- И снова посмотрим план запросов — обычная таблица распараллеливается
-- И снова посмотрим план запросов — обычная таблица распараллеливается
\echo EXPLAIN ANALYZE SELECT * FROM t_temp8;
EXPLAIN ANALYZE SELECT * FROM t_temp8;
\echo EXPLAIN ANALYZE SELECT * FROM temp8;
EXPLAIN ANALYZE SELECT * FROM temp8;

\echo -- Удаляем лишнее
-- Удаляем лишнее

\echo DROP TABLE temp8;
DROP TABLE temp8;
