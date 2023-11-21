\echo -- 6. Временная схема и обычная роль
-- 6. Временная схема и обычная роль

\echo CREATE ROLE check_tmp LOGIN;
CREATE ROLE check_tmp LOGIN;
\echo SHOW hba_file;
SHOW hba_file;
\echo \! sudo sed -i -e "1 s/^/"'local      all     check_tmp       trust '"\n/;" /etc/postgresql/16/main/pg_hba.conf;
\! sudo sed -i -e "1 s/^/"'local      all     check_tmp       trust '"\n/;" /etc/postgresql/16/main/pg_hba.conf;
\echo SELECT * FROM pg_hba_file_rules;
SELECT * FROM pg_hba_file_rules;
\echo SELECT pg_reload_conf();
SELECT pg_reload_conf();

\echo \c - check_tmp 
\c - check_tmp 
\echo \conninfo
\conninfo

\echo -- Проверка — все команды из пятого эксперимента
-- Проверка — все команды из пятого эксперимента

\echo -- Обратить внимание на результат команды удаления схемы
-- Обратить внимание на результат команды удаления схемы
\echo -- ERROR:  must be owner of schema pg_temp_3
-- ERROR:  must be owner of schema pg_temp_3
\echo -- И на последнюю команду — для схемы pg_temp_3 есть название
-- И на последнюю команду — для схемы pg_temp_3 есть название

\echo -- Создаем таблицу, смотрим схему
-- Создаем таблицу, смотрим схему

\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo CREATE TEMP TABLE t_temp6 (id integer);
CREATE TEMP TABLE t_temp6 (id integer);
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;

\echo -- Добавим строки, проверим временную схему и строки из таблицы
-- Добавим строки, проверим временную схему и строки из таблицы

\echo INSERT INTO t_temp6 VALUES (1),(2),(3);
INSERT INTO t_temp6 VALUES (1),(2),(3);
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
\echo   _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp6'));
\echo   OPEN _cursor FOR EXECUTE _query;
\echo END
\echo $$;

DO $$
DECLARE
  _query text;
  _cursor CONSTANT refcursor := '_cursor';
BEGIN
  _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp6'));
  OPEN _cursor FOR EXECUTE _query;
END
$$;

\echo FETCH ALL FROM _cursor;
FETCH ALL FROM _cursor;
\echo COMMIT;
COMMIT;

\echo -- Попробуем удалить временную схему (аналог  DROP SCHEMA name)
-- Попробуем удалить временную схему (аналог  DROP SCHEMA name)

\echo DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace; END $$;
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace; END $$;

\echo -- Повторим с CASCADE
-- Повторим с CASCADE

\echo DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);

\echo -- Создадим еще одну временную таблицу
-- Создадим еще одну временную таблицу

\echo CREATE TEMP TABLE t_temp6_2 (id integer);
CREATE TEMP TABLE t_temp6_2 (id integer);
\echo SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SHOW search_path;
SHOW search_path;
\echo INSERT INTO t_temp6_2 VALUES (1), (2), (3);
INSERT INTO t_temp6_2 VALUES (1), (2), (3);

\echo -- Временная схема не определяется
-- Временная схема не определяется

\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
\echo SELECT * FROM pg_temp.t_temp6_2;
SELECT * FROM pg_temp.t_temp6_2;
\echo SELECT * FROM pg_temp_3.t_temp6_2;
SELECT * FROM pg_temp_3.t_temp6_2;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);
\echo SELECT * FROM pg_catalog.pg_namespace;
SELECT * FROM pg_catalog.pg_namespace;

\echo -- Проверим что пишут в системном каталоге
-- Проверим что пишут в системном каталоге

\echo SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6_2';
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6_2';
\echo SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6');
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6');
\echo SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6'));
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6'));

\echo -- Удаляем лишнее
-- Удаляем лишнее

\echo DROP TABLE t_temp6;
DROP TABLE t_temp6;
\echo DROP TABLE t_temp6_2;
DROP TABLE t_temp6_2;
\echo \c - pavel
\c - pavel
\echo DROP ROLE check_tmp;
DROP ROLE check_tmp;
