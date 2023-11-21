-- 5. Временная схема и суперпользователь
-- Создаем таблицу, смотрим схему
 
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
CREATE TEMP TABLE t_temp5 (id integer);
CREATE TABLE
 
SELECT current_schemas(true);
        current_schemas        
-------------------------------
 {pg_temp_3,pg_catalog,public}
(1 row)
 
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
      nspname       
--------------------
 information_schema
 pg_catalog
 pg_temp_3
 pg_temp_4
 pg_toast
 pg_toast_temp_3
 pg_toast_temp_4
 public
(8 rows)
 
-- Добавим строки, проверим временную схему и строки из таблицы
 
INSERT INTO t_temp5 VALUES (1),(2),(3);
INSERT 0 3
 
SELECT pg_my_temp_schema()::regnamespace;
 pg_my_temp_schema 
-------------------
 pg_temp_3
(1 row)
 
BEGIN;
BEGIN
 
-- Анонимный блок нужен чтобы сформировать полное имя: схема.таблица
 
DO $$
DECLARE
_query text;
_cursor CONSTANT refcursor := _cursor;
BEGIN
_query := SELECT * FROM  || (SELECT n.nspname || . || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp5'));
OPEN _cursor FOR EXECUTE _query;
END
$$;
DO
 
FETCH ALL FROM _cursor;
 id 
----
  1
  2
  3
(3 rows)
 
COMMIT;
COMMIT
 
-- Попробуем удалить временную схему (аналог  DROP SCHEMA name)
 
DO $$ BEGIN EXECUTE DROP SCHEMA || pg_my_temp_schema()::regnamespace; END $$;
psql:5.sql:55: ERROR:  cannot drop schema pg_temp_3 because other objects depend on it
DETAIL:  table t_temp5 depends on schema pg_temp_3
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
CONTEXT:  SQL statement "DROP SCHEMA IF EXISTS pg_temp_3"
PL/pgSQL function inline_code_block line 1 at EXECUTE
 
-- Повторим с CASCADE (схема удалилась успешно)
 
DO $$ BEGIN EXECUTE DROP SCHEMA || pg_my_temp_schema()::regnamespace ||  CASCADE; END $$;
psql:5.sql:57: NOTICE:  drop cascades to table t_temp5
DO
 
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
-- Создадим еще одну временную таблицу
 
CREATE TEMP TABLE t_temp5_2 (id integer);
CREATE TABLE
 
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
      nspname       
--------------------
 information_schema
 pg_catalog
 pg_temp_4
 pg_toast
 pg_toast_temp_3
 pg_toast_temp_4
 public
(7 rows)
 
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
SHOW search_path;
   search_path   
-----------------
 "$user", public
(1 row)
 
INSERT INTO t_temp5_2 VALUES (1), (2), (3);
INSERT 0 3
 
-- OID временной схемы есть, но записи в pg_namespace для него нет
 
SELECT pg_my_temp_schema()::regnamespace;
 pg_my_temp_schema 
-------------------
 482607
(1 row)
 
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
 nspname 
---------
(0 rows)
 
SELECT * FROM pg_temp.t_temp5_2;
 id 
----
  1
  2
  3
(3 rows)
 
SELECT * FROM pg_temp_3.t_temp5_2;
psql:5.sql:85: ERROR:  relation "pg_temp_3.t_temp5_2" does not exist
LINE 1: SELECT * FROM pg_temp_3.t_temp5_2;
                      ^
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
SELECT * FROM pg_catalog.pg_namespace;
  oid   |      nspname       | nspowner |                            nspacl                             
--------+--------------------+----------+---------------------------------------------------------------
     99 | pg_toast           |       10 | 
     11 | pg_catalog         |       10 | {postgres=UC/postgres,=U/postgres}
   2200 | public             |     6171 | {pg_database_owner=UC/pg_database_owner,=U/pg_database_owner}
  13250 | information_schema |       10 | {postgres=UC/postgres,=U/postgres}
 432342 | pg_temp_4          |       10 | 
 432516 | pg_toast_temp_3    |       10 | 
 432571 | pg_toast_temp_4    |       10 | 
(7 rows)
 
-- Проверим что пишут в системном каталоге
 
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5_2';
  oid   |  relname  
--------+-----------
 482611 | t_temp5_2
(1 row)
 
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5');
 oid | relnamespace 
-----+--------------
(0 rows)
 
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5'));
 oid | nspname | nspowner | nspacl 
-----+---------+----------+--------
(0 rows)