\echo -- 7. Auto {analyze|vacuum} временной и обычной таблицы
-- 7. Auto {analyze|vacuum} временной и обычной таблицы

\echo -- Добавлю настройки ускорения авто -вакуума и -анализа
-- Добавлю настройки ускорения авто -вакуума и -анализа
\echo ALTER SYSTEM SET autovacuum_naptime = 1;
ALTER SYSTEM SET autovacuum_naptime = 1;
\echo ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.01;
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.01;
\echo ALTER SYSTEM SET autovacuum_vacuum_threshold = 0;
ALTER SYSTEM SET autovacuum_vacuum_threshold = 0;
\echo ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.02;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.02;
\echo ALTER SYSTEM SET autovacuum_analyze_threshold = 0;
ALTER SYSTEM SET autovacuum_analyze_threshold = 0;

\echo -- Перечитаю конфигурацию
-- Перечитаю конфигурацию

\echo SELECT pg_reload_conf();
SELECT pg_reload_conf();

\echo -- Создадим две таблицы (обычную и временную)
-- Создадим две таблицы (обычную и временную)
\echo -- И заполним их данными
-- И заполним их данными

\echo CREATE TEMP TABLE t_temp7 (id integer);
CREATE TEMP TABLE t_temp7 (id integer);
\echo INSERT INTO t_temp7 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO t_temp7 SELECT * FROM generate_series(1,1_000_000);

\echo CREATE TABLE temp7 (id integer);
CREATE TABLE temp7 (id integer);
\echo INSERT INTO temp7 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO temp7 SELECT * FROM generate_series(1,1_000_000);

\echo -- Сделаем небольшую паузу
-- Сделаем небольшую паузу

\echo SELECT pg_sleep(2);
SELECT pg_sleep(2);

\echo -- Проверим собранную статистику по таблицам
-- Проверим собранную статистику по таблицам

\echo SELECT pg_sleep(2);
SELECT pg_sleep(2);
\echo SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
\echo SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';

\echo SELECT count(*) FROM t_temp7;
SELECT count(*) FROM t_temp7;
\echo SELECT count(*) FROM temp7;
SELECT count(*) FROM temp7;

\echo SELECT null_frac, avg_width, n_distinct, correlation
SELECT null_frac, avg_width, n_distinct, correlation
\echo FROM pg_stats s
FROM pg_stats s
\echo WHERE s.tablename = 't_temp7' AND s.attname = 'id';
WHERE s.tablename = 't_temp7' AND s.attname = 'id';

\echo SELECT null_frac, avg_width, n_distinct, correlation
SELECT null_frac, avg_width, n_distinct, correlation
\echo FROM pg_stats s
FROM pg_stats s
\echo WHERE s.tablename = 'temp7' AND s.attname = 'id';
WHERE s.tablename = 'temp7' AND s.attname = 'id';

\echo -- Показания отличаются 
-- Показания отличаются 
\echo -- Для временной таблицы автоанализ не срабатывает
-- Для временной таблицы автоанализ не срабатывает
\echo -- Соберём статистику по временной таблице руками
-- Соберём статистику по временной таблице руками

\echo ANALYZE t_temp7;
ANALYZE t_temp7;
\echo SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
\echo SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';

\echo SELECT null_frac, avg_width, n_distinct, correlation
SELECT null_frac, avg_width, n_distinct, correlation
\echo FROM pg_stats s
FROM pg_stats s
\echo WHERE s.tablename = 't_temp7' AND s.attname = 'id';
WHERE s.tablename = 't_temp7' AND s.attname = 'id';

\echo SELECT null_frac, avg_width, n_distinct, correlation
SELECT null_frac, avg_width, n_distinct, correlation
\echo FROM pg_stats s
FROM pg_stats s
\echo WHERE s.tablename = 'temp7' AND s.attname = 'id';
WHERE s.tablename = 'temp7' AND s.attname = 'id';

\echo -- Проверим размер полученных таблиц
-- Проверим размер полученных таблиц

\echo SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('t_temp7'));
\echo SELECT pg_size_pretty(pg_table_size('temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));

\echo -- Обновим все строки в таблицах и снова проверим размер
-- Обновим все строки в таблицах и снова проверим размер

\echo UPDATE t_temp7 SET id = id + 1;
UPDATE t_temp7 SET id = id + 1;
\echo UPDATE temp7 SET id = id + 1;
UPDATE temp7 SET id = id + 1;

\echo SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('t_temp7'));
\echo SELECT pg_size_pretty(pg_table_size('temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));

\echo -- Удалим все строки из таблиц
-- Удалим все строки из таблиц

\echo DELETE FROM t_temp7;
DELETE FROM t_temp7;
\echo DELETE FROM temp7;
DELETE FROM temp7;

\echo -- Сделаем небольшую задержку
-- Сделаем небольшую задержку

\echo SELECT pg_sleep(3);
SELECT pg_sleep(3);

\echo -- Автовакуум не очищает временную таблицу
-- Автовакуум не очищает временную таблицу

\echo SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('t_temp7'));
\echo SELECT pg_size_pretty(pg_table_size('temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));

\echo -- Сделаем очистку руками
-- Сделаем очистку руками

\echo VACUUM t_temp7;
VACUUM t_temp7;
\echo SELECT pg_sleep(3);
SELECT pg_sleep(3);
\echo SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('t_temp7'));
\echo SELECT pg_size_pretty(pg_table_size('temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));

\echo -- Удалим лишнее
-- Удалим лишнее

\echo DROP TABLE temp7;
DROP TABLE temp7;

\echo -- И настройки тоже
-- И настройки тоже
\echo ALTER SYSTEM RESET autovacuum_naptime;
ALTER SYSTEM RESET autovacuum_naptime;
\echo ALTER SYSTEM RESET autovacuum_vacuum_scale_factor;
ALTER SYSTEM RESET autovacuum_vacuum_scale_factor;
\echo ALTER SYSTEM RESET autovacuum_vacuum_threshold;
ALTER SYSTEM RESET autovacuum_vacuum_threshold;
\echo ALTER SYSTEM RESET autovacuum_analyze_scale_factor;
ALTER SYSTEM RESET autovacuum_analyze_scale_factor;
\echo ALTER SYSTEM RESET autovacuum_analyze_threshold;
ALTER SYSTEM RESET autovacuum_analyze_threshold;

\echo -- Перечитаю конфигурацию
-- Перечитаю конфигурацию

\echo SELECT pg_reload_conf();
SELECT pg_reload_conf();