-- 7. Auto {analyze|vacuum} временной и обычной таблицы
-- Добавлю настройки ускорения авто -вакуума и -анализа
 
ALTER SYSTEM SET autovacuum_naptime = 1;
ALTER SYSTEM
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.01;
ALTER SYSTEM
ALTER SYSTEM SET autovacuum_vacuum_threshold = 0;
ALTER SYSTEM
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.02;
ALTER SYSTEM
ALTER SYSTEM SET autovacuum_analyze_threshold = 0;
ALTER SYSTEM
 
-- Перечитаю конфигурацию
 
SELECT pg_reload_conf();
 pg_reload_conf 
----------------
 t
(1 row)
 
-- Создадим две таблицы (обычную и временную)
-- И заполним их данными
 
CREATE TEMP TABLE t_temp7 (id integer);
CREATE TABLE
INSERT INTO t_temp7 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
CREATE TABLE temp7 (id integer);
CREATE TABLE
INSERT INTO temp7 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
 
-- Сделаем небольшую паузу
SELECT pg_sleep(2);
 pg_sleep 
----------
  
(1 row)
 
-- Проверим собранную статистику по таблицам
SELECT pg_sleep(2);
 pg_sleep 
----------
  
(1 row)
 
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
 reltuples | relpages 
-----------+----------
        -1 |        0
(1 row)
 
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
 reltuples | relpages 
-----------+----------
     1e+06 |     4425
(1 row)
 
SELECT count(*) FROM t_temp7;
  count 
---------
 1000000
(1 row)
 
SELECT count(*) FROM temp7;
  count 
---------
 1000000
(1 row)
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 't_temp7' AND s.attname = 'id';
 null_frac | avg_width | n_distinct | correlation 
-----------+-----------+------------+-------------
(0 rows)
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 'temp7' AND s.attname = 'id';
 null_frac | avg_width | n_distinct | correlation 
-----------+-----------+------------+-------------
         0 |         4 |         -1 |           1
(1 row)
 
-- Показания отличаются
-- Для временной таблицы автоанализ не срабатывает
-- Соберём статистику по временной таблице руками
 
ANALYZE t_temp7;
ANALYZE
 
SELECT reltuples, relpages FROM pg_class WHERE relname = 't_temp7';
 reltuples | relpages 
-----------+----------
     1e+06 |     4425
(1 row)
 
SELECT reltuples, relpages FROM pg_class WHERE relname = 'temp7';
 reltuples | relpages 
-----------+----------
     1e+06 |     4425
(1 row)
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 't_temp7' AND s.attname = 'id';
 null_frac | avg_width | n_distinct | correlation 
-----------+-----------+------------+-------------
         0 |         4 |         -1 |           1
(1 row)
 
SELECT null_frac, avg_width, n_distinct, correlation
FROM pg_stats s
WHERE s.tablename = 'temp7' AND s.attname = 'id';
 null_frac | avg_width | n_distinct | correlation 
-----------+-----------+------------+-------------
         0 |         4 |         -1 |           1
(1 row)
 
-- Проверим размер полученных таблиц
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
 pg_size_pretty 
----------------
 35 MB
(1 row)
 
SELECT pg_size_pretty(pg_table_size('temp7'));
 pg_size_pretty 
----------------
 35 MB
(1 row)
 
-- Обновим все строки в таблицах и снова проверим размер
 
UPDATE t_temp7 SET id = id + 1;
UPDATE 1000000
UPDATE temp7 SET id = id + 1;
UPDATE 1000000
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
 pg_size_pretty 
----------------
 69 MB
(1 row)
 
SELECT pg_size_pretty(pg_table_size('temp7'));
 pg_size_pretty 
----------------
 69 MB
(1 row)
 
-- Удалим все строки из таблиц
 
DELETE FROM t_temp7;
DELETE 1000000
DELETE FROM temp7;
DELETE 1000000
 
-- Сделаем небольшую задержку
 
SELECT pg_sleep(3);
 pg_sleep 
----------
  
(1 row)
 
-- Автовакуум не очищает временную таблицу
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
 pg_size_pretty 
----------------
 69 MB
(1 row)
 
SELECT pg_size_pretty(pg_table_size('temp7'));
 pg_size_pretty 
----------------
 16 kB
(1 row)
 
-- Сделаем очистку руками
 
VACUUM t_temp7;
VACUUM
 
SELECT pg_sleep(3);
 pg_sleep 
----------
  
(1 row)
 
SELECT pg_size_pretty(pg_table_size('t_temp7'));
 pg_size_pretty 
----------------
 16 kB
(1 row)
 
SELECT pg_size_pretty(pg_table_size('temp7'));
 pg_size_pretty 
----------------
 16 kB
(1 row)
 
-- Удалим лишнее
DROP TABLE temp7;
DROP TABLE
-- И настройки тоже
ALTER SYSTEM RESET autovacuum_naptime;
ALTER SYSTEM
ALTER SYSTEM RESET autovacuum_vacuum_scale_factor;
ALTER SYSTEM
ALTER SYSTEM RESET autovacuum_vacuum_threshold;
ALTER SYSTEM
ALTER SYSTEM RESET autovacuum_analyze_scale_factor;
ALTER SYSTEM
ALTER SYSTEM RESET autovacuum_analyze_threshold;
ALTER SYSTEM
-- Перечитаю конфигурацию
SELECT pg_reload_conf();
 pg_reload_conf 
----------------
 t
(1 row)