-- 6. Временная схема и обычная роль
 
CREATE ROLE check_tmp LOGIN;
SHOW hba_file;
\! sudo sed -i -e "1 s/^/"'local      all     check_tmp       trust '"\n/;" /etc/postgresql/16/main/pg_hba.conf;
SELECT * FROM pg_hba_file_rules;
SELECT pg_reload_conf();
 
\c - check_tmp 
\conninfo
 
-- Проверка — все команды из пятого эксперимента
 
-- Обратить внимание на результат команды удаления схемы
-- ERROR:  must be owner of schema pg_temp_3
-- И на последнюю команду — для схемы pg_temp_3 есть название
 
-- Создаем таблицу, смотрим схему
 
SELECT current_schemas(true);
CREATE TEMP TABLE t_temp6 (id integer);
SELECT current_schemas(true);
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
 
-- Добавим строки, проверим временную схему и строки из таблицы
 
INSERT INTO t_temp6 VALUES (1),(2),(3);
SELECT pg_my_temp_schema()::regnamespace;
BEGIN;
 
-- Анонимный блок нужен чтобы сформировать полное имя: схема.таблица
 
DO $$
DECLARE
  _query text;
  _cursor CONSTANT refcursor := '_cursor';
BEGIN
  _query := 'SELECT * FROM ' || (SELECT n.nspname || '.' || c.relname relname FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace LEFT JOIN pg_catalog.pg_am am ON am.oid = c.relam WHERE c.relname = ('t_temp6'));
  OPEN _cursor FOR EXECUTE _query;
END
$$;
FETCH ALL FROM _cursor;
COMMIT;
 
-- Попробуем удалить временную схему (аналог  DROP SCHEMA name)
 
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace; END $$;
 
-- Повторим с CASCADE
 
DO $$ BEGIN EXECUTE 'DROP SCHEMA ' ||  pg_my_temp_schema()::regnamespace || ' CASCADE'; END $$;
SELECT current_schemas(true);
 
-- Создадим еще одну временную таблицу
 
CREATE TEMP TABLE t_temp6_2 (id integer);
SELECT n.nspname FROM pg_catalog.pg_namespace n ORDER BY 1;
SELECT current_schemas(true);
SHOW search_path;
INSERT INTO t_temp6_2 VALUES (1), (2), (3);
 
-- Временная схема не определяется
 
SELECT pg_my_temp_schema()::regnamespace;
SELECT nspname FROM pg_namespace WHERE oid = pg_my_temp_schema();
SELECT * FROM pg_temp.t_temp6_2;
SELECT * FROM pg_temp_3.t_temp6_2;
SELECT current_schemas(true);
SELECT * FROM pg_catalog.pg_namespace;
 
-- Проверим что пишут в системном каталоге
 
SELECT c.oid, c.relname FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6_2';
SELECT oid, relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6');
SELECT * FROM pg_namespace WHERE oid = (SELECT relnamespace FROM pg_class WHERE oid = (SELECT c.oid FROM pg_catalog.pg_class c WHERE c.relname = 't_temp6'));
 
-- Удаляем лишнее
 
DROP TABLE t_temp6;
DROP TABLE t_temp6_2;
\c - pavel
DROP ROLE check_tmp;
