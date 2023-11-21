-- 10. Временные таблица, индекс, TOAST и их расположение на диске
 
-- ТАБЛИЦА t_temp10
CREATE TEMP  TABLE t_temp10(val text);
-- Индекс на таблицу t_temp10
CREATE INDEX i_t_temp10 ON t_temp10 (val);
-- НАЗВАНИЕ временной схемы
SELECT pg_my_temp_schema()::regnamespace;
-- НАЗВАНИЕ временной TOAST схемы
SELECT n.nspname FROM pg_catalog.pg_class c 
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (
SELECT relname FROM pg_class WHERE OID = (
SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
 
--  Однако, план запроса с опцией VERBOSE показывает без цифр
 
EXPLAIN (ANALYZE, VERBOSE) select * from t_temp10;
 
-- OID таблицы t_temp10
 
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 't_temp10';
 
-- OID индекса i_t_temp10
 
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 'i_t_temp10';
 
-- OID TOAST-таблицы на t_temp10
 
SELECT relfilenode, relname FROM pg_class WHERE OID = (  
  SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
 
-- OID TOAST-таблицы на t_temp10 с именем временной схемы
 
SELECT c.oid, n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (
  SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
 
-- Индекс на TOAST-таблицу
 
SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
 
-- Индекс на TOAST-таблицу на t_temp10 с именем временной схемы
 
SELECT c.oid, n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
  WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
 
-- Текущая БД
 
SELECT * FROM current_database();
 
-- OID текущей БД
 
SELECT oid, datname FROM pg_catalog.pg_database WHERE datname = (SELECT * FROM current_database());
 
-- Адрес  t_temp10 на диске
 
SELECT pg_relation_filepath('t_temp10') temp10_table;
 
-- Адрес  i_t_temp10 на диске
 
SELECT pg_relation_filepath('i_t_temp10') temp10_index;
 
-- Адрес  TOAST-таблицы на диске
 
SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
  WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_table;
 
-- Адрес индекса на TOAST-таблицу на диске
 
SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
  WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_temp10_index;
 
-- Проверим на диске
 
SHOW data_directory;
 
\! sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
