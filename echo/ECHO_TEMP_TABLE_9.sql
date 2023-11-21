\echo -- Подготовка — создадим роль check_tmp, настроим доступ pg_hba
-- Подготовка — создадим роль check_tmp, настроим доступ pg_hba

\echo -- Проверим значение пар-ра temp_buffers
-- Проверим значение пар-ра temp_buffers
\echo SHOW temp_buffers;
SHOW temp_buffers;

\echo -- Увеличим его
-- Увеличим его
\echo SET temp_buffers = '16MB';
SET temp_buffers = '16MB';

\echo -- Создадим временную таблицу и снова увеличим значение пар-ра
-- Создадим временную таблицу и снова увеличим значение пар-ра
\echo CREATE TEMP TABLE t_temp9 (id integer);
CREATE TEMP TABLE t_temp9 (id integer);

\echo SET temp_buffers = '32MB';
SET temp_buffers = '32MB';

\echo -- Вроде бы обращаемся к временной таблице - но пар-р снова можно изменить
-- Вроде бы обращаемся к временной таблице - но пар-р снова можно изменить
\echo SELECT * FROM t_temp9;
SELECT * FROM t_temp9;

\echo SET temp_buffers = '16MB';
SET temp_buffers = '16MB';

\echo -- Но после изменения данных во временной таблице уже нельзя менять значение пар-ра
-- Но после изменения данных во временной таблице уже нельзя менять значение пар-ра
\echo INSERT INTO t_temp9 VALUES (1);
INSERT INTO t_temp9 VALUES (1);

\echo SET temp_buffers = '32MB';
SET temp_buffers = '32MB';

\echo -- В плане чтение из локального кеша отображается как LOCAL READ/HIT
-- В плане чтение из локального кеша отображается как LOCAL READ/HIT
\echo EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;

\echo \c
\c

\echo SET temp_buffers = '1024 kB';
SET temp_buffers = '1024 kB';

\echo CREATE TEMP TABLE t_temp9 (id integer);
CREATE TEMP TABLE t_temp9 (id integer);
\echo CREATE TABLE temp9 (id integer);
CREATE TABLE temp9 (id integer);
\echo INSERT INTO t_temp9 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO t_temp9 SELECT * FROM generate_series(1,1_000_000);
\echo INSERT INTO temp9 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO temp9 SELECT * FROM generate_series(1,1_000_000);
\echo SELECT count(*) FROM temp9;
SELECT count(*) FROM temp9;
\echo -- local read
-- local read
\echo EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;

\echo -- Удаляем лишнее
-- Удаляем лишнее
\echo DROP TABLE temp9;
DROP TABLE temp9;