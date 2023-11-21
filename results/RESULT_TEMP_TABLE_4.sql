-- 4. Временная таблица, представление и функция
-- Создадим временную таблицу
 
CREATE TEMP TABLE t_temp4 (id integer);
CREATE TABLE
 
-- Создадим представление на основе временной таблицы
 
CREATE VIEW v_t_temp4 AS SELECT * FROM t_temp4;
psql:4.sql:13: NOTICE:  view "v_t_temp4" will be a temporary view
CREATE VIEW
 
-- Посмотрим где представление хранится на диске
 
SELECT pg_relation_filepath(v_t_temp4);
 pg_relation_filepath 
----------------------
  
(1 row)
 
-- Создадим обычную таблицу
 
CREATE TABLE temp4 (id integer);
CREATE TABLE
 
-- Создадим представление на основе обычной таблицы
 
CREATE VIEW v_temp4 AS SELECT * FROM temp4;
CREATE VIEW
 
-- И посмотрим где это представление хранится на диске
 
SELECT pg_relation_filepath(v_temp4);
 pg_relation_filepath 
----------------------
  
(1 row)
 
-- Создадим функцию
 
CREATE FUNCTION f_t_func()
RETURNS integer
AS $$
SELECT count(*) FROM v_t_temp4;
$$ LANGUAGE sql;
CREATE FUNCTION
 
SELECT f_t_func();
 f_t_func 
----------
        0
(1 row)
 
CREATE MATERIALIZED VIEW mv AS SELECT * FROM t_temp4 ;
psql:4.sql:57: ERROR:  materialized views must not use temporary tables or views
 
-- Удалим таблицу
 
DROP TABLE t_temp4;
psql:4.sql:63: ERROR:  cannot drop table t_temp4 because other objects depend on it
DETAIL:  view v_t_temp4 depends on table t_temp4
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
 
-- Удалим таблицу и каскадно все объекты, связанные с ней
 
DROP TABLE t_temp4 CASCADE;
psql:4.sql:69: NOTICE:  drop cascades to view v_t_temp4
DROP TABLE
 
-- Удалим лишние объекты
 
DROP TABLE temp4 CASCADE;
psql:4.sql:75: NOTICE:  drop cascades to view v_temp4
DROP TABLE
 
DROP FUNCTION f_t_func;
DROP FUNCTION