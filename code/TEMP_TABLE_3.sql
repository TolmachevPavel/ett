-- 3. Табличное пространство по умолчанию для временных объектов 
-- («По умолчанию значение этой переменной — пустая строка. 
-- С таким значением все временные объекты создаются в табличном
-- пространстве по умолчанию, установленном для текущей базы данных»)
SHOW temp_tablespaces;
 
-- Табличное пространство по умолчанию
 
SHOW default_tablespace;
 
-- Табличное пространство по умолчанию для текущей БД
 
SELECT db.datname, ts.spcname 
FROM pg_tablespace ts JOIN pg_database db 
ON db.dattablespace = ts.oid 
WHERE db.datname = (SELECT * FROM current_database());
 
-- Изменим табличное пространство по умолчанию
 
SET temp_tablespaces = pg_global;
 
-- Снова создадим временную таблицу
 
CREATE TEMP TABLE t_temp3(id integer);
 
-- Создадим обычную таблицу
 
CREATE TABLE t_temp3(id integer);
