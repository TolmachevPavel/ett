-- 10. Временные таблица, индекс, TOAST и их расположение на диске
 
-- ТАБЛИЦА t_temp10
 
CREATE TEMP TABLE t_temp10(val text);
CREATE TABLE
 
-- Индекс на таблицу t_temp10
 
CREATE INDEX i_t_temp10 ON t_temp10 (val);
CREATE INDEX
 
-- НАЗВАНИЕ временной схемы
 
SELECT pg_my_temp_schema()::regnamespace;
 
 pg_my_temp_schema 
-------------------
 pg_temp_3
(1 row)
 
-- НАЗВАНИЕ временной TOAST схемы
 
SELECT n.nspname FROM pg_catalog.pg_class c 
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
    LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (
  SELECT relname FROM pg_class WHERE OID = (
    SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
     nspname     
-----------------
 pg_toast_temp_3
(1 row)
 
-- Однако, план запроса с опцией VERBOSE показывает без цифр
 
EXPLAIN (ANALYZE, VERBOSE) select * from t_temp10;
                                                  QUERY PLAN                                                   
---------------------------------------------------------------------------------------------------------------
 Seq Scan on pg_temp.t_temp10  (cost=0.00..23.60 rows=1360 width=32) (actual time=0.002..0.004 rows=0 loops=1)
   Output: val
 Planning Time: 0.084 ms
 Execution Time: 0.012 ms
(4 rows)
 
-- OID таблицы t_temp10
 
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 't_temp10';
  oid   | relname  
--------+----------
 490781 | t_temp10
(1 row)
 
-- OID индекса i_t_temp10
 
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 'i_t_temp10';
  oid   |  relname   
--------+------------
 490786 | i_t_temp10
(1 row)
 
-- OID TOAST-таблицы на t_temp10
 
SELECT relfilenode, relname FROM pg_class WHERE OID = (
SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
 relfilenode |     relname     
-------------+-----------------
      490784 | pg_toast_490781
(1 row)
 
-- OID TOAST-таблицы на t_temp10 с именем временной схемы
 
SELECT c.oid, n.nspname || . || c.relname relname
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (
SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
  oid   |             relname             
--------+---------------------------------
 490784 | pg_toast_temp_3.pg_toast_490781
(1 row)
 
-- Индекс на TOAST-таблицу
 
SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
       ?column?        
-----------------------
 pg_toast_490781_index
(1 row)
 
-- Индекс на TOAST-таблицу на t_temp10 с именем временной схемы
 
SELECT c.oid, n.nspname || . || c.relname relname
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
  oid   |                relname                
--------+---------------------------------------
 490785 | pg_toast_temp_3.pg_toast_490781_index
(1 row)
 
-- Текущая БД
 
SELECT * FROM current_database();
 current_database 
------------------
 pavel
(1 row)
 
-- OID текущей БД
 
SELECT oid, datname FROM pg_catalog.pg_database WHERE datname = (SELECT * FROM current_database());
  oid  | datname 
-------+---------
 16391 | pavel
(1 row)
 
-- Адрес t_temp10 на диске
 
SELECT pg_relation_filepath('t_temp10') temp10_table;
     temp10_table     
----------------------
 base/16391/t3_490781
(1 row)
 
-- Адрес i_t_temp10 на диске
 
SELECT pg_relation_filepath('i_t_temp10') temp10_index;
     temp10_index     
----------------------
 base/16391/t3_490786
(1 row)
 
-- Адрес TOAST-таблицы на диске
 
SELECT pg_relation_filepath((SELECT n.nspname || . || c.relname relname
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_table;
     toast_table      
----------------------
 base/16391/t3_490784
(1 row)
 
-- Адрес индекса на TOAST-таблицу на диске
 
SELECT pg_relation_filepath((SELECT n.nspname || . || c.relname relname
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_temp10_index;
  toast_temp10_index  
----------------------
 base/16391/t3_490785
(1 row)
 
SHOW data_directory;
       data_directory        
-----------------------------
 /var/lib/postgresql/16/main
(1 row)
 
-- Проверим на диске
sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
-rw-------  1 postgres postgres         0 ноя 20 18:20 t3_490781
-rw-------  1 postgres postgres         0 ноя 20 18:20 t3_490784
-rw-------  1 postgres postgres      8192 ноя 20 18:20 t3_490785
-rw-------  1 postgres postgres      8192 ноя 20 18:20 t3_490786