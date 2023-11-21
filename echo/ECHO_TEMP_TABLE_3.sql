\echo -- 3. Табличное пространство по умолчанию для временных объектов
-- 3. Табличное пространство по умолчанию для временных объектов

\echo SHOW temp_tablespaces;
SHOW temp_tablespaces;

\echo -- Табличное пространство по умолчанию
-- Табличное пространство по умолчанию

\echo SHOW default_tablespace;
SHOW default_tablespace;

\echo -- Табличное пространство по умолчанию для текущей БД
-- Табличное пространство по умолчанию для текущей БД

\echo SELECT db.datname, ts.spcname 
SELECT db.datname, ts.spcname 
\echo FROM pg_tablespace ts JOIN pg_database db 
FROM pg_tablespace ts JOIN pg_database db 
\echo ON db.dattablespace = ts.oid 
ON db.dattablespace = ts.oid 
\echo WHERE db.datname = (SELECT * FROM current_database());
WHERE db.datname = (SELECT * FROM current_database());

\echo -- Изменим табличное пространство по умолчанию
-- Изменим табличное пространство по умолчанию

\echo SET temp_tablespaces = pg_global;
SET temp_tablespaces = pg_global;

\echo -- Снова создадим временную таблицу
-- Снова создадим временную таблицу

\echo CREATE TEMP TABLE t_temp3(id integer);
CREATE TEMP TABLE t_temp3(id integer);

\echo -- Создадим обычную таблицу
-- Создадим обычную таблицу

\echo CREATE TABLE t_temp3(id integer);
CREATE TABLE t_temp3(id integer);

\echo -- Удалим лишнее
-- Удалим лишнее
\echo DROP TABLE t_temp_3;
DROP TABLE t_temp3;
\echo SET temp_tablespaces = pg_default;
SET temp_tablespaces = pg_default;