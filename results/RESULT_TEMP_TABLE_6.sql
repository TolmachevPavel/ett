-- 6. Временная схема и обычная роль
-- pavel — это роль суперпользователя
 
CREATE ROLE check_tmp LOGIN;
CREATE ROLE
SHOW hba_file;
              hba_file               
-------------------------------------
 /etc/postgresql/16/main/pg_hba.conf
(1 row)
 
 
SELECT * FROM pg_hba_file_rules;
 rule_number |              file_name              | line_number | type  |   database    |  user_name  | address  |                 netmask                 |  auth_method  | options | error 
-------------+-------------------------------------+-------------+-------+---------------+-------------+----------+-----------------------------------------+---------------+---------+-------
           1 | /etc/postgresql/16/main/pg_hba.conf |           1 | local | {all}         | {check_tmp} |          |                                         | trust         |         | 
          14 | /etc/postgresql/16/main/pg_hba.conf |         123 | local | {all}         | {postgres}  |          |                                         | peer          |         | 
          15 | /etc/postgresql/16/main/pg_hba.conf |         128 | local | {all}         | {all}       |          |                                         | peer          |         | 
          16 | /etc/postgresql/16/main/pg_hba.conf |         129 | local | {pavel}       | {pavel}     |          |                                         | trust         |         | 
          17 | /etc/postgresql/16/main/pg_hba.conf |         131 | host  | {all}         | {all}       | 127.0.0..| 255.255.255.255                         | scram-sha-256 |         | 
             |                                     |             |       |               |             |.1        |                                         |               |         | 
          18 | /etc/postgresql/16/main/pg_hba.conf |         133 | host  | {all}         | {all}       | ::1      | ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff | scram-sha-256 |         | 
          19 | /etc/postgresql/16/main/pg_hba.conf |         136 | local | {replication} | {all}       |          |                                         | peer          |         | 
          20 | /etc/postgresql/16/main/pg_hba.conf |         137 | host  | {replication} | {all}       | 127.0.0..| 255.255.255.255                         | scram-sha-256 |         | 
             |                                     |             |       |               |             |.1        |                                         |               |         | 
          21 | /etc/postgresql/16/main/pg_hba.conf |         138 | host  | {replication} | {all}       | ::1      | ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff | scram-sha-256 |         | 
(21 rows)
 
SELECT pg_reload_conf();
 pg_reload_conf 
----------------
 t
(1 row)
 
\c - check_tmp 
You are now connected to database "pavel" as user "check_tmp".
\conninfo
You are connected to database "pavel" as user "check_tmp" via socket in "/var/run/postgresql" at port "5432".
 
-- Проверка — все команды из пятого эксперимента
-- Обратить внимание на результат команды удаления схемы
-- ERROR: must be owner of schema pg_temp_3
-- И на последнюю команду — для схемы pg_temp_3 есть название
-- Создаем таблицу, смотрим схему
 
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
CREATE TEMP TABLE t_temp6 (id integer);
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
INSERT INTO t_temp6 VALUES (1),(2),(3);
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
_query := SELECT * FROM  || (SELECT n.nspname || . || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp6'));
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
 
-- Попробуем удалить временную схему (аналог DROP SCHEMA name)
DO $$ BEGIN EXECUTE DROP SCHEMA  || pg_my_temp_schema()::regnamespace; END $$;
psql:6.sql:84: ERROR:  must be owner of schema pg_temp_3
CONTEXT:  SQL statement "DROP SCHEMA pg_temp_3"
PL/pgSQL function inline_code_block line 1 at EXECUTE
 
-- Повторим с CASCADE
 
DO $$ BEGIN EXECUTE DROP SCHEMA  || pg_my_temp_schema()::regnamespace ||  CASCADE; END $$;
psql:6.sql:90: ERROR:  must be owner of schema pg_temp_3
CONTEXT:  SQL statement "DROP SCHEMA pg_temp_3 CASCADE"
PL/pgSQL function inline_code_block line 1 at EXECUTE
 
SELECT current_schemas(true);
        current_schemas        
-------------------------------
 {pg_temp_3,pg_catalog,public}
(1 row)
 
-- Создадим еще одну временную таблицу
CREATE TEMP TABLE t_temp6_2 (id integer);
CREATE TABLE
 
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
 
SELECT current_schemas(true);
        current_schemas        
-------------------------------
 {pg_temp_3,pg_catalog,public}
(1 row)
 
SHOW search_path;
   search_path   
-----------------
 "$user", public
(1 row)
 
INSERT INTO t_temp6_2 VALUES (1), (2), (3);
INSERT 0 3
 
-- Временная схема не определяется
 
SELECT pg_my_temp_schema()::regnamespace;
 pg_my_temp_schema 
-------------------
 pg_temp_3
(1 row)
 
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
  nspname  
-----------
 pg_temp_3
(1 row)
 
SELECT * FROM pg_temp.t_temp6_2;
 id 
----
  1
  2
  3
(3 rows)
 
SELECT * FROM pg_temp_3.t_temp6_2;
 id 
----
  1
  2
  3
(3 rows)
 
SELECT current_schemas(true);
        current_schemas        
-------------------------------
 {pg_temp_3,pg_catalog,public}
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
 482748 | pg_temp_3          |       10 | 
(8 rows)
 
-- Проверим что пишут в системном каталоге
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6_2';
  oid   |  relname  
--------+-----------
 482794 | t_temp6_2
(1 row)
 
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6');
  oid   | relnamespace 
--------+--------------
 482791 |       482748
(1 row)
 
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6'));
  oid   |  nspname  | nspowner | nspacl 
--------+-----------+----------+--------
 482748 | pg_temp_3 |       10 | 
(1 row)
 
-- Удаляем лишнее
 
DROP TABLE t_temp6;
DROP TABLE
DROP TABLE t_temp6_2;
DROP TABLE
 
\c - pavel
You are now connected to database "pavel" as user "pavel".
 
DROP ROLE check_tmp;
DROP ROLE