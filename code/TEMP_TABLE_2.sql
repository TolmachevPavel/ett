-- 2. Временная таблица и путь поиска
-- Проверим временную схему сеанса, пути поиска
 
SELECT pg_my_temp_schema()::regnamespace;
SHOW search_path;
SELECT current_schemas(true);
 
-- Создадим обычную таблицу, добавим туда строки
 
CREATE TABLE temp2 (id integer);
INSERT INTO temp2 VALUES (1),(2),(3);
SELECT * FROM temp2;
 
-- Создадим временную таблицу с аналогичным названием
 
CREATE TEMP TABLE temp2 (id integer);
 
-- Снова проверим временную схему сеанса и пути поиска
 
SELECT pg_my_temp_schema()::regnamespace;
SHOW search_path;
SELECT current_schemas(true);
 
-- Выполним эксперимент
 
SELECT * FROM temp2;
SELECT * FROM public.temp2;
SELECT * FROM pg_temp.temp2;
DROP TABLE temp2;
SELECT * FROM temp2;
 
-- Удалим лишние объекты
 
DROP TABLE public.temp2;