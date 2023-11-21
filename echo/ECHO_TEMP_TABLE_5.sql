\echo -- 5. Временная схема и суперпользователь
-- 5. Временная схема и суперпользователь
\echo -- Создаем таблицу, смотрим схему
-- Создаем таблицу, смотрим схему

\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo CREATE TEMP TABLE t_temp5 (id integer);
CREATE TEMP TABLE t_temp5 (id integer);
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;

\echo -- Добавим строки, проверим временную схему и строки из таблицы
-- Добавим строки, проверим временную схему и строки из таблицы

\echo INSERT INTO t_temp5 VALUES (1),(2),(3);
INSERT INTO t_temp5 VALUES (1),(2),(3);
\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo BEGIN;
BEGIN;

\echo -- Анонимный блок нужен чтобы сформировать полное имя: схема.таблица
-- Анонимный блок нужен чтобы сформировать полное имя: схема.таблица

\echo DO $$
\echo DECLARE
\echo   _query text;
\echo   _cursor CONSTANT refcursor := '_cursor';
\echo BEGIN
\echo   _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp5'));
\echo   OPEN _cursor FOR EXECUTE _query;
\echo END
\echo $$;

DO $$
DECLARE
  _query text;
  _cursor CONSTANT refcursor := '_cursor';
BEGIN
  _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp5'));
  OPEN _cursor FOR EXECUTE _query;
END
$$;

\echo FETCH ALL FROM _cursor;
FETCH ALL FROM _cursor;
\echo COMMIT;
COMMIT;

\echo -- Попробуем удалить временную схему
-- Попробуем удалить временную схему

\echo DO $$ BEGIN EXECUTE 'DROP SCHEMA IF EXISTS ' ||  pg_my_temp_schema()::regnamespace; END $$;
DO $$ BEGIN EXECUTE 'DROP SCHEMA IF EXISTS ' ||  pg_my_temp_schema()::regnamespace; END $$;
\echo DO $$ BEGIN EXECUTE 'DROP SCHEMA IF EXISTS ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
DO $$ BEGIN EXECUTE 'DROP SCHEMA IF EXISTS ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);

\echo -- Создадим еще одну временную таблицу
-- Создадим еще одну временную таблицу

\echo CREATE TEMP TABLE t_temp5_2 (id integer);
CREATE TEMP TABLE t_temp5_2 (id integer);
\echo SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SHOW search_path;
SHOW search_path;
\echo INSERT INTO t_temp5_2 VALUES (1), (2), (3);
INSERT INTO t_temp5_2 VALUES (1), (2), (3);

\echo -- Временная схема не определяется
-- Временная схема не определяется

\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
\echo SELECT * FROM pg_temp.t_temp5_2;
SELECT * FROM pg_temp.t_temp5_2;
\echo SELECT * FROM pg_temp_3.t_temp5_2;
SELECT * FROM pg_temp_3.t_temp5_2;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SELECT * FROM pg_catalog.pg_namespace;
SELECT * FROM pg_catalog.pg_namespace;

\echo -- Проверим что пишут в системном каталоге
-- Проверим что пишут в системном каталоге

\echo SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5_2';
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5_2';
\echo SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5');
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5');
\echo SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5'));
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5'));