-- 7. Auto {analyze|vacuum} временной и обычной таблицы
 
-- Добавлю настройки ускорения авто -вакуума и -анализа
ALTER SYSTEM SET autovacuum_naptime = 1;
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.01;
ALTER SYSTEM SET autovacuum_vacuum_threshold = 0;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.02;
ALTER SYSTEM SET autovacuum_analyze_threshold = 0;
 
-- Перечитаю конфигурацию
 
SELECT pg_reload_conf();
 
-- Создадим две таблицы (обычную и временную)
-- И заполним их данными
 
CREATE TEMP TABLE t_temp7 (id integer);
INSERT INTO t_temp7 SELECT * FROM generate_series(1,1_000_000);
 
CREATE TABLE temp7 (id integer);
INSERT INTO temp7 SELECT * FROM generate_series(1,1_000_000);
 
-- Сделаем небольшую паузу
 
SELECT pg_sleep(2);
 
-- Проверим собранную статистику по таблицам
 
SELECT pg_sleep(2);
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
 
SELECT count(*) FROM t_temp7;
SELECT count(*) FROM temp7;
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 't_temp7' AND s.attname = 'id';
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 'temp7' AND s.attname = 'id';
 
-- Показания отличаются 
-- Для временной таблицы автоанализ не срабатывает
-- Соберём статистику по временной таблице руками
 
ANALYZE t_temp7;
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 't_temp7' AND s.attname = 'id';
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 'temp7' AND s.attname = 'id';
 
-- Проверим размер полученных таблиц
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));
 
-- Обновим все строки в таблицах и снова проверим размер
 
UPDATE t_temp7 SET id = id + 1;
UPDATE temp7 SET id = id + 1;
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));
 
-- Удалим все строки из таблиц
 
DELETE FROM t_temp7;
DELETE FROM temp7;
 
-- Сделаем небольшую задержку
 
SELECT pg_sleep(3);
 
-- Автовакуум не очищает временную таблицу
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));
 
-- Сделаем очистку руками
 
VACUUM t_temp7;
SELECT pg_sleep(3);
SELECT pg_size_pretty(pg_table_size('t_temp7'));
SELECT pg_size_pretty(pg_table_size('temp7'));
 
-- Удалим лишнее
 
DROP TABLE temp7;
 
-- И настройки тоже
ALTER SYSTEM RESET autovacuum_naptime;
ALTER SYSTEM RESET autovacuum_vacuum_scale_factor;
ALTER SYSTEM RESET autovacuum_vacuum_threshold;
ALTER SYSTEM RESET autovacuum_analyze_scale_factor;
ALTER SYSTEM RESET autovacuum_analyze_threshold;
 
-- Перечитаю конфигурацию
 
SELECT pg_reload_conf();
