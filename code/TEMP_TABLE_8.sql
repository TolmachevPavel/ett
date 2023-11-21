-- 8. Параллельная обработка временных таблиц
-- Создадим две таблицы, одну временную, другую обычную
 
CREATE TEMP TABLE t_temp8 (id integer);
CREATE TABLE temp8 (id integer);
 
-- Добавим туда по миллиону строк
INSERT INTO t_temp8 SELECT * FROM generate_series(1,1_000_000);
INSERT INTO temp8 SELECT * FROM generate_series(1,1_000_000);
 
-- Руками сделаем анализ
ANALYZE t_temp8;
ANALYZE temp8;
 
-- Посмотрим план запросов
EXPLAIN ANALYZE SELECT * FROM t_temp8;
EXPLAIN ANALYZE SELECT * FROM temp8;
 
-- Установим пар-р, с помощью которого можно посмотреть параллельный план
SHOW debug_parallel_query;
SET debug_parallel_query = on;
 
-- И снова посмотрим план запросов — обычная таблица распараллеливается
EXPLAIN ANALYZE SELECT * FROM t_temp8;
EXPLAIN ANALYZE SELECT * FROM temp8;
 
-- Удаляем лишнее
 
DROP TABLE temp8;
