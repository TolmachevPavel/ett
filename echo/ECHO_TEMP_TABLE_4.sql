\echo -- 4. Временная таблица, представление и функция
-- 4. Временная таблица, представление и функция
\echo -- Создадим временную таблицу
-- Создадим временную таблицу

\echo CREATE TEMP TABLE t_temp4 (id integer);
CREATE TEMP TABLE t_temp4 (id integer);

\echo -- Создадим представление на основе временной таблицы
-- Создадим представление на основе временной таблицы

\echo CREATE VIEW v_t_temp4 AS SELECT * FROM t_temp4;
CREATE VIEW v_t_temp4 AS SELECT * FROM t_temp4;

\echo -- Посмотрим где представление хранится на диске
-- Посмотрим где представление хранится на диске

\echo SELECT pg_relation_filepath('v_t_temp4');
SELECT pg_relation_filepath('v_t_temp4');

\echo -- Создадим обычную таблицу
-- Создадим обычную таблицу

\echo CREATE TABLE temp4 (id integer);
CREATE TABLE temp4 (id integer);

\echo -- Создадим представление на основе обычной таблицы
-- Создадим представление на основе обычной таблицы

\echo CREATE VIEW v_temp4 AS SELECT * FROM temp4;
CREATE VIEW v_temp4 AS SELECT * FROM temp4;

\echo -- И посмотрим где это представление хранится на диске
-- И посмотрим где это представление хранится на диске

\echo SELECT pg_relation_filepath('v_temp4');
SELECT pg_relation_filepath('v_temp4');

\echo -- Создадим функцию
-- Создадим функцию

\echo CREATE FUNCTION f_t_func()
\echo RETURNS integer
\echo AS $$
\echo SELECT count(*) FROM v_t_temp4;
\echo $$ LANGUAGE sql;
CREATE FUNCTION f_t_func()
RETURNS integer
AS $$
SELECT count(*) FROM v_t_temp4;
$$ LANGUAGE sql;

\echo SELECT f_t_func();
SELECT f_t_func();

\echo CREATE MATERIALIZED VIEW mv AS SELECT * FROM t_temp4 ;
CREATE MATERIALIZED VIEW mv AS SELECT * FROM t_temp4 ;

\echo -- Удалим таблицу
-- Удалим таблицу

\echo DROP TABLE t_temp4; 
DROP TABLE t_temp4; 

\echo -- Удалим таблицу и каскадно все объекты, связанные с ней
-- Удалим таблицу и каскадно все объекты, связанные с ней

\echo DROP TABLE t_temp4 CASCADE; 
DROP TABLE t_temp4 CASCADE; 

\echo -- Удалим лишние объекты
-- Удалим лишние объекты

\echo DROP TABLE temp4 CASCADE;
DROP TABLE temp4 CASCADE;

\echo DROP FUNCTION f_t_func;
DROP FUNCTION f_t_func;
