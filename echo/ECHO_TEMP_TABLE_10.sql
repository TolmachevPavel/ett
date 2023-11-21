\echo -- 10. Временные таблица, индекс, TOAST и их расположение на диске
-- 10. Временные таблица, индекс, TOAST и их расположение на диске

\echo -- ТАБЛИЦА t_temp10
-- ТАБЛИЦА t_temp10
\echo CREATE TEMP  TABLE t_temp10(val text);
CREATE TEMP  TABLE t_temp10(val text);
\echo -- Индекс на таблицу t_temp10
-- Индекс на таблицу t_temp10
\echo CREATE INDEX i_t_temp10 ON t_temp10 (val);
CREATE INDEX i_t_temp10 ON t_temp10 (val);
\echo -- НАЗВАНИЕ временной схемы
-- НАЗВАНИЕ временной схемы
\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo -- НАЗВАНИЕ временной TOAST схемы
-- НАЗВАНИЕ временной TOAST схемы
\echo SELECT n.nspname FROM pg_catalog.pg_class c 
\echo LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
\echo LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (
\echo   SELECT relname FROM pg_class WHERE OID = (
\echo   SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));

SELECT n.nspname FROM pg_catalog.pg_class c 
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (
  SELECT relname FROM pg_class WHERE OID = (
    SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));

\echo --  Однако, план запроса с опцией VERBOSE показывает без цифр
--  Однако, план запроса с опцией VERBOSE показывает без цифр

\echo EXPLAIN (ANALYZE, VERBOSE) select * from t_temp10;
EXPLAIN (ANALYZE, VERBOSE) select * from t_temp10;

\echo -- OID таблицы t_temp10
-- OID таблицы t_temp10

\echo SELECT c.oid, c.relname
\echo FROM pg_catalog.pg_class c
\echo WHERE c.relname = 't_temp10';
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 't_temp10';

\echo -- OID индекса i_t_temp10
-- OID индекса i_t_temp10

\echo SELECT c.oid, c.relname
\echo FROM pg_catalog.pg_class c
\echo WHERE c.relname = 'i_t_temp10';
SELECT c.oid, c.relname
FROM pg_catalog.pg_class c
WHERE c.relname = 'i_t_temp10';

\echo -- OID TOAST-таблицы на t_temp10
-- OID TOAST-таблицы на t_temp10

\echo SELECT relfilenode, relname FROM pg_class WHERE OID = (
  \echo SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
	SELECT relfilenode, relname FROM pg_class WHERE OID = (  
  SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');

\echo -- OID TOAST-таблицы на t_temp10 с именем временной схемы
-- OID TOAST-таблицы на t_temp10 с именем временной схемы

\echo SELECT c.oid, n.nspname || '.' || c.relname relname
\echo FROM pg_catalog.pg_class c
     \echo LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     \echo LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (
  \echo SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));       
SELECT c.oid, n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
	 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		 LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (
  SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));

\echo -- Индекс на TOAST-таблицу
-- Индекс на TOAST-таблицу

\echo SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');
SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10');

\echo -- Индекс на TOAST-таблицу на t_temp10 с именем временной схемы
-- Индекс на TOAST-таблицу на t_temp10 с именем временной схемы

\echo SELECT c.oid, n.nspname || '.' || c.relname relname
\echo FROM pg_catalog.pg_class c
     \echo LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     \echo LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
\echo WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));
SELECT c.oid, n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
	 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	 LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10'));

\echo -- Текущая БД
-- Текущая БД

\echo SELECT * FROM current_database();
SELECT * FROM current_database();

\echo -- OID текущей БД
-- OID текущей БД

\echo SELECT oid, datname FROM pg_catalog.pg_database WHERE datname = (SELECT * FROM current_database());
SELECT oid, datname FROM pg_catalog.pg_database WHERE datname = (SELECT * FROM current_database());

\echo -- Адрес  t_temp10 на диске
-- Адрес  t_temp10 на диске

\echo SELECT pg_relation_filepath('t_temp10') temp10_table;
SELECT pg_relation_filepath('t_temp10') temp10_table;

\echo -- Адрес  i_t_temp10 на диске
-- Адрес  i_t_temp10 на диске

\echo SELECT pg_relation_filepath('i_t_temp10') temp10_index;
SELECT pg_relation_filepath('i_t_temp10') temp10_index;

\echo -- Адрес  TOAST-таблицы на диске
-- Адрес  TOAST-таблицы на диске

\echo SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
\echo FROM pg_catalog.pg_class c
\echo LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
\echo LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
\echo WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_table;
SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
								   LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
								   LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_table;

\echo -- Адрес индекса на TOAST-таблицу на диске
-- Адрес индекса на TOAST-таблицу на диске

\echo SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
\echo FROM pg_catalog.pg_class c
\echo LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
\echo LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
\echo WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_temp10_index;
SELECT pg_relation_filepath((SELECT n.nspname || '.' || c.relname relname
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam
WHERE c.relname = (SELECT relname || '_index' FROM pg_class WHERE OID = (SELECT reltoastrelid FROM pg_class WHERE relname='t_temp10')))) TOAST_temp10_index;

\echo -- Проверим на диске
-- Проверим на диске

\echo SHOW data_directory;
SHOW data_directory;

\echo "\! sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3"
\! sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3