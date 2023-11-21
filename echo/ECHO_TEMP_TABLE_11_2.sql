\echo -- Проверяем параметр
-- Проверяем параметр

\echo SHOW remove_temp_files_after_crash;
SHOW remove_temp_files_after_crash;

\echo CREATE TEMP TABLE t_temp11 (id integer);
CREATE TEMP TABLE t_temp11 (id integer);
\echo INSERT INTO t_temp11 VALUES (1),(2),(3);
INSERT INTO t_temp11 VALUES (1),(2),(3);

\echo SELECT pg_relation_filepath('t_temp11');
SELECT pg_relation_filepath('t_temp11');
\echo SHOW data_directory;
SHOW data_directory;

\echo -- ID обслуживающего процесса
-- ID обслуживающего процесса
\echo SELECT pg_backend_pid();
SELECT pg_backend_pid();