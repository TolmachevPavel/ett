-- 1. Временная таблица on commit {reserver|delete|drop}
-- ON COMMIT PRESERVE ROWS — строки в таблице сохраняются до конца сессии
-- ON COMMIT DROP — таблица удаляется после завершения транзакции
-- ON COMMIT DELETE ROWS — все строки таблицы будут удалены после фиксации транзакции
 
-- Создаем три временные таблицы с разным поведением
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TABLE
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TABLE
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
CREATE TABLE
 
-- Добавляем в них строки
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT 0 1000
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT 0 1000
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
psql:1.sql:23: ERROR:  relation "t_temp1_3" does not exist
LINE 1: INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000)...
 
-- Смотрим что в таблицах
SELECT count(*) FROM t_temp1_1;
 count
-------
  1000
(1 row)
 
SELECT count(*) FROM t_temp1_2;
 count
-------
     0
(1 row)
 
SELECT count(*) FROM t_temp1_3;
psql:1.sql:32: ERROR:  relation "t_temp1_3" does not exist
LINE 1: SELECT count(*) FROM t_temp1_3;
 
-- Доступно только две временные таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like t_temp1%;
 schemaname | tablename 
------------+-----------
 pg_temp_3  | t_temp1_1
 pg_temp_3  | t_temp1_2
(2 rows)
 
-- Удаляем их
DROP TABLE t_temp1_1;
DROP TABLE
DROP TABLE t_temp1_2;
DROP TABLE
 
-- Начинаем новую транзакцию
BEGIN;
BEGIN
 
-- Создаем три временные таблицы с разным поведением
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TABLE
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TABLE
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
CREATE TABLE
 
-- Добавляем в них строки
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT 0 1000
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT 0 1000
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
INSERT 0 1000
 
-- В транзакции видны все три временные таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like t_temp1%;
 schemaname | tablename 
------------+-----------
 pg_temp_3  | t_temp1_1
 pg_temp_3  | t_temp1_2
 pg_temp_3  | t_temp1_3
(3 rows)
 
-- Смотрим что в них
SELECT count(*) FROM t_temp1_1;
 count
-------
  1000
(1 row)
 
SELECT count(*) FROM t_temp1_2;
 count
-------
  1000
(1 row)
 
SELECT count(*) FROM t_temp1_3;
 count
-------
  1000
(1 row)
 
COMMIT;
COMMIT
 
-- После завершения транзакции снова доступно две таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like t_temp1%;
 schemaname | tablename 
------------+-----------
 pg_temp_3  | t_temp1_1
 pg_temp_3  | t_temp1_2
(2 rows)
 
-- И в одной из них все строки удалены
SELECT count(*) FROM t_temp1_1;
 count
-------
  1000
(1 row)
 
SELECT count(*) FROM t_temp1_2;
 count
-------
     0
(1 row)
 
SELECT count(*) FROM t_temp1_3;
psql:1.sql:89: ERROR:  relation "t_temp1_3" does not exist
LINE 1: SELECT count(*) FROM t_temp1_3;