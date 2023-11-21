-- 1. Временная таблица on commit {reserver|delete|drop}
-- ON COMMIT PRESERVE ROWS — строки в таблице сохраняются до конца сессии
-- ON COMMIT DROP — таблица удаляется после завершения транзакции
-- ON COMMIT DELETE ROWS — все строки таблицы будут удалены после фиксации транзакции
 
-- Создаем три временные таблицы с разным поведением
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
 
-- Добавляем в них строки
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
 
-- Смотрим что в таблицах
SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_3;
 
-- Доступно только две временные таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
 
-- Удаляем их
DROP TABLE t_temp1_1;
DROP TABLE t_temp1_2;
 
-- Начинаем новую транзакцию
BEGIN;
 
-- Создаем три временные таблицы с разным поведением
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
 
-- Добавляем в них строки
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
 
-- В транзакции видны все три временные таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
 
-- Смотрим что в них
SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_3;
 
COMMIT;
 
-- После завершения транзакции снова доступно две таблицы
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
 
-- И в одной из них все строки удалены
SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_3;