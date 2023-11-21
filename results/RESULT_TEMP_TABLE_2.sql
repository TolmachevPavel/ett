-- 2. Временная таблица и путь поиска
-- Проверим временную схему сеанса, пути поиска
 
SELECT pg_my_temp_schema()::regnamespace;
 pg_my_temp_schema 
-------------------
 -
(1 row)
 
SHOW search_path;
   search_path   
-----------------
 "$user", public
(1 row)
 
SELECT current_schemas(true);
   current_schemas   
---------------------
 {pg_catalog,public}
(1 row)
 
-- Создадим обычную таблицу, добавим туда строки
 
CREATE TABLE temp2 (id integer);
CREATE TABLE
INSERT INTO temp2 VALUES (1),(2),(3);
INSERT 0 3
SELECT * FROM temp2;
 id 
----
  1
  2
  3
(3 rows)
 
-- Создадим временную таблицу с аналогичным названием
CREATE TEMP TABLE temp2 (id integer);
CREATE TABLE
 
-- Снова проверим временную схему сеанса и пути поиска
SELECT pg_my_temp_schema()::regnamespace;
 pg_my_temp_schema 
-------------------
 pg_temp_3
(1 row)
 
SHOW search_path;
   search_path   
-----------------
 "$user", public
(1 row)
 
SELECT current_schemas(true);
        current_schemas        
-------------------------------
 {pg_temp_3,pg_catalog,public}
(1 row)
 
-- Выполним эксперимент
SELECT * FROM temp2;
 id 
----
(0 rows)
 
SELECT * FROM public.temp2;
 id 
----
  1
  2
  3
(3 rows)
 
SELECT * FROM pg_temp.temp2;
 id 
----
(0 rows)
 
DROP TABLE temp2;
DROP TABLE
 
SELECT * FROM temp2;
 id 
----
  1
  2
  3
(3 rows)
 
-- Удалим лишние объекты
DROP TABLE public.temp2;
DROP TABLE