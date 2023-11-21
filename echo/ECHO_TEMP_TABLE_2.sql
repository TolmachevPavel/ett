\echo -- 2. Временная таблица и путь поиска
-- 2. Временная таблица и путь поиска
\echo -- Проверим временную схему сеанса, пути поиска
-- Проверим временную схему сеанса, пути поиска

\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo SHOW search_path;
SHOW search_path;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);

\echo -- Создадим обычную таблицу, добавим туда строки
-- Создадим обычную таблицу, добавим туда строки

\echo CREATE TABLE temp2 (id integer);
CREATE TABLE temp2 (id integer);
\echo INSERT INTO temp2 VALUES (1),(2),(3);
INSERT INTO temp2 VALUES (1),(2),(3);
\echo SELECT * FROM temp2;
SELECT * FROM temp2;

\echo -- Создадим временную таблицу с аналогичным названием
-- Создадим временную таблицу с аналогичным названием

\echo CREATE TEMP TABLE temp2 (id integer);
CREATE TEMP TABLE temp2 (id integer);

\echo -- Снова проверим временную схему сеанса и пути поиска
-- Снова проверим временную схему сеанса и пути поиска

\echo SELECT pg_my_temp_schema()::regnamespace;
SELECT pg_my_temp_schema()::regnamespace;
\echo SHOW search_path;
SHOW search_path;
\echo SELECT current_schemas(true);
SELECT current_schemas(true);

\echo -- Выполним эксперимент
-- Выполним эксперимент

\echo SELECT * FROM temp2;
SELECT * FROM temp2;
\echo SELECT * FROM public.temp2;
SELECT * FROM public.temp2;
\echo SELECT * FROM pg_temp.temp2;
SELECT * FROM pg_temp.temp2;
\echo DROP TABLE temp2;
DROP TABLE temp2;
\echo SELECT * FROM temp2;
SELECT * FROM temp2;

\echo -- Удалим лишние объекты
-- Удалим лишние объекты

\echo DROP TABLE public.temp2;
DROP TABLE public.temp2;