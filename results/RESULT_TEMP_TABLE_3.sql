-- 3. Табличное пространство по умолчанию для временных объектов 
-- («По умолчанию значение этой переменной — пустая строка. 
-- С таким значением все временные объекты создаются в табличном
-- пространстве по умолчанию, установленном для текущей базы данных»)
SHOW temp_tablespaces;
 temp_tablespaces 
------------------
  
(1 row)
 
-- Табличное пространство по умолчанию
 
SHOW default_tablespace;
 default_tablespace 
--------------------
  
(1 row)
 
-- Табличное пространство по умолчанию для текущей БД
 
SELECT db.datname, ts.spcname
FROM pg_tablespace ts JOIN pg_database db
ON db.dattablespace = ts.oid
WHERE db.datname = (SELECT * FROM current_database());
 datname |  spcname   
---------+------------
 pavel   | pg_default
(1 row)
 
-- Изменим табличное пространство по умолчанию
 
SET temp_tablespaces = pg_global;
SET
 
-- Снова создадим временную таблицу
 
CREATE TEMP TABLE t_temp3(id integer);
psql:3.sql:35: ERROR:  only shared relations can be placed in pg_global tablespace
 
-- Создадим обычную таблицу
 
CREATE TABLE t_temp3(id integer);
CREATE TABLE
 
-- Удалим лишнее
 
DROP TABLE t_temp_3;
DROP TABLE