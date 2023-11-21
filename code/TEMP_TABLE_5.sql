-- 5. Временная схема и суперпользователь
-- Создаем таблицу, смотрим схему
 
SELECT current_schemas(true);
CREATE TEMP TABLE t_temp5 (id integer);
SELECT current_schemas(true);
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
 
-- Добавим строки, проверим временную схему и строки из таблицы
 
INSERT INTO t_temp5 VALUES (1),(2),(3);
SELECT pg_my_temp_schema()::regnamespace;
BEGIN;
 
-- Анонимный блок нужен чтобы сформировать полное имя: схема.таблица
 
DO $$
DECLARE
  _query text;
  _cursor CONSTANT refcursor := '_cursor';
BEGIN
  _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp5'));
  OPEN _cursor FOR EXECUTE _query;
END
$$;
FETCH ALL FROM _cursor;
COMMIT;
 
-- Попробуем удалить временную схему (аналог  DROP SCHEMA name)
 
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace; END $$;
 
-- Повторим с CASCADE (схема удалилась успешно)
 
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
SELECT current_schemas(true);
-- Создадим еще одну временную таблицу
 
CREATE TEMP TABLE t_temp5_2 (id integer);
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT current_schemas(true);
SHOW search_path;
INSERT INTO t_temp5_2 VALUES (1), (2), (3);
 
-- Временная схема не определяется
 
SELECT pg_my_temp_schema()::regnamespace;
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
SELECT * FROM pg_temp.t_temp5_2;
SELECT * FROM pg_temp_3.t_temp5_2;
SELECT current_schemas(true);
SELECT * FROM pg_catalog.pg_namespace;
 
-- Проверим что пишут в системном каталоге
 
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5_2';
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5');
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp5'));
