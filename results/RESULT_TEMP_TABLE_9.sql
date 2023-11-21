-- 9. Параметр temp_buffers
 
-- Подготовка — создадим роль check_tmp, настроим доступ pg_hba
-- Проверим значение пар-ра temp_buffers
 
SHOW temp_buffers;
 temp_buffers 
--------------
 8MB
(1 row)
 
-- Увеличим его
 
SET temp_buffers = 16MB;
SET
 
-- Создадим временную таблицу и снова увеличим значение пар-ра
 
CREATE TEMP TABLE t_temp9 (id integer);
CREATE TABLE
 
SET temp_buffers = 32MB;
SET
 
-- Вроде бы обращаемся к временной таблице - но пар-р снова можно изменить
 
SELECT * FROM t_temp9;
 id 
----
(0 rows)
 
SET temp_buffers = 16MB;
SET
 
-- Но после изменения данных во временной таблице уже нельзя менять значение пар-ра
 
INSERT INTO t_temp9 VALUES (1);
INSERT 0 1
 
SET temp_buffers = 32MB;
psql:9.sql:36: ERROR:  invalid value for parameter "temp_buffers": 4096
DETAIL:  "temp_buffers" cannot be changed after any temporary tables have been accessed in the session.
 
-- В плане чтение из локального кеша отображается как LOCAL READ/HIT
 
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
                                                QUERY PLAN                                                 
-----------------------------------------------------------------------------------------------------------
 Aggregate  (cost=41.88..41.88 rows=1 width=8) (actual time=0.016..0.023 rows=1 loops=1)
   Buffers: local hit=1
   -&gt;  Seq Scan on t_temp9  (cost=0.00..35.50 rows=2550 width=0) (actual time=0.006..0.009 rows=1 loops=1)
         Buffers: local hit=1
 Planning:
   Buffers: shared hit=3
 Planning Time: 0.046 ms
 Execution Time: 0.130 ms
(8 rows)
 
\c
You are now connected to database "pavel" as user "pavel".
 
SET temp_buffers = 1024 kB;
SET
 
CREATE TEMP TABLE t_temp9 (id integer);
CREATE TABLE
CREATE TABLE temp9 (id integer);
CREATE TABLE
 
INSERT INTO t_temp9 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
INSERT INTO temp9 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
 
SELECT count(*) FROM temp9;
  count 
---------
 1000000
(1 row)
 
-- local read
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM t_temp9;
                                                        QUERY PLAN                                                        
--------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=18529.69..18529.70 rows=1 width=8) (actual time=2452.049..2452.055 rows=1 loops=1)
   Buffers: local read=4425 dirtied=4425 written=4423
   -&gt;  Seq Scan on t_temp9  (cost=0.00..15708.75 rows=1128375 width=0) (actual time=0.027..1232.810 rows=1000000 loops=1)
         Buffers: local read=4425 dirtied=4425 written=4423
 Planning:
   Buffers: shared hit=4
 Planning Time: 0.048 ms
 Execution Time: 2452.079 ms
(8 rows)
 
-- Удаляем лишнее
DROP TABLE temp9;
DROP TABLE