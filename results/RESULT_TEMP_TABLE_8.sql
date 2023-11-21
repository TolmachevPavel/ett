-- 8. Параллельная обработка временных таблиц
-- Создадим две таблицы, одну временную, другую обычную
 
CREATE TEMP TABLE t_temp8 (id integer);
CREATE TABLE
CREATE TABLE temp8 (id integer);
CREATE TABLE
 
-- Добавим туда по миллиону строк
 
INSERT INTO t_temp8 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
INSERT INTO temp8 SELECT * FROM generate_series(1,1_000_000);
INSERT 0 1000000
 
-- Руками сделаем анализ
 
ANALYZE t_temp8;
ANALYZE
ANALYZE temp8;
ANALYZE
 
-- Посмотрим план запросов
 
EXPLAIN ANALYZE SELECT * FROM t_temp8;
                                                     QUERY PLAN                                                     
--------------------------------------------------------------------------------------------------------------------
 Seq Scan on t_temp8  (cost=0.00..14425.00 rows=1000000 width=4) (actual time=0.029..1249.628 rows=1000000 loops=1)
 Planning Time: 0.045 ms
 Execution Time: 2440.071 ms
(3 rows)
 
EXPLAIN ANALYZE SELECT * FROM temp8;
                                                    QUERY PLAN                                                    
------------------------------------------------------------------------------------------------------------------
 Seq Scan on temp8  (cost=0.00..14425.00 rows=1000000 width=4) (actual time=0.011..1237.203 rows=1000000 loops=1)
 Planning Time: 0.069 ms
 Execution Time: 2431.272 ms
(3 rows)
 
-- Установим пар-р, с помощью которого можно посмотреть параллельный план
 
SHOW debug_parallel_query;
 debug_parallel_query 
----------------------
 off
(1 row)
 
SET debug_parallel_query = on;
SET
 
-- И снова посмотрим план запросов — обычная таблица распараллеливается
 
EXPLAIN ANALYZE SELECT * FROM t_temp8;
                                                     QUERY PLAN                                                     
--------------------------------------------------------------------------------------------------------------------
 Seq Scan on t_temp8  (cost=0.00..14425.00 rows=1000000 width=4) (actual time=0.011..1245.712 rows=1000000 loops=1)
 Planning Time: 0.034 ms
 Execution Time: 2435.330 ms
(3 rows)
 
EXPLAIN ANALYZE SELECT * FROM temp8;
                                                       QUERY PLAN                                                       
------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..115425.00 rows=1000000 width=4) (actual time=4.182..1309.885 rows=1000000 loops=1)
   Workers Planned: 1
   Workers Launched: 1
   Single Copy: true
   -&gt;  Seq Scan on temp8  (cost=0.00..14425.00 rows=1000000 width=4) (actual time=0.013..1297.671 rows=1000000 loops=1)
 Planning Time: 0.032 ms
 Execution Time: 2594.434 ms
(7 rows)
 
-- Удаляем лишнее
 
DROP TABLE temp8;
DROP TABLE