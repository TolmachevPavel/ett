-- 4. Временная таблица, представление и функция
-- Создадим временную таблицу
 
CREATE TEMP TABLE t_temp4 (id integer);
 
-- Создадим представление на основе временной таблицы
 
CREATE VIEW v_t_temp4 AS SELECT * FROM t_temp4;
 
-- Посмотрим где представление хранится на диске
 
SELECT pg_relation_filepath('v_t_temp4');
 
-- Создадим обычную таблицу
 
CREATE TABLE temp4 (id integer);
 
-- Создадим представление на основе обычной таблицы
 
CREATE VIEW v_temp4 AS SELECT * FROM temp4;
 
-- И посмотрим где это представление хранится на диске
 
SELECT pg_relation_filepath('v_temp4');
 
-- Создадим функцию
 
CREATE FUNCTION f_t_func()
RETURNS integer
AS $$
SELECT count(*) FROM v_t_temp4;
$$ LANGUAGE sql;
 
SELECT f_t_func();
 
CREATE MATERIALIZED VIEW mv AS SELECT * FROM t_temp4 ;
 
-- Удалим таблицу
 
DROP TABLE t_temp4; 
 
-- Удалим таблицу и каскадно все объекты, связанные с ней
 
DROP TABLE t_temp4 CASCADE; 
 
-- Удалим лишние объекты
 
DROP TABLE temp4 CASCADE;
 
DROP FUNCTION f_t_func;
