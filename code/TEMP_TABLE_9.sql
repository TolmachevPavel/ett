-- 9. Параметр temp_buffers
-- Подготовка — создадим роль check_tmp, настроим доступ pg_hba
-- Проверим значение пар-ра temp_buffers
 
SHOW temp_buffers;
 
-- Увеличим его
SET temp_buffers = '16MB';
 
-- Создадим временную таблицу и снова увеличим значение пар-ра
CREATE TEMP TABLE t_temp9 (id integer);
 
SET temp_buffers = '32MB';
 
-- Вроде бы обращаемся к временной таблице - но пар-р снова можно изменить
SELECT * FROM t_temp9;
 
SET temp_buffers = '16MB';
 
-- Но после изменения данных во временной таблице уже нельзя менять значение пар-ра
INSERT INTO t_temp9 VALUES (1);
 
SET temp_buffers = '32MB';
 
-- В плане чтение из локального кеша отображается как LOCAL READ/HIT
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
 
\c
 
SET temp_buffers = '1024 kB';
 
CREATE TEMP TABLE t_temp9 (id integer);
CREATE TABLE temp9 (id integer);
INSERT INTO t_temp9 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO temp9 SELECT * FROM generate_series(1,1_000_000);
SELECT count(*) FROM temp9;
 
-- local read
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
 
-- Удаляем лишнее
DROP TABLE temp9;
