-- Проверяем параметр

SHOW remove_temp_files_after_crash;

CREATE TEMP TABLE t_temp11 (id integer);
INSERT INTO t_temp11 VALUES (1),(2),(3);

SELECT pg_relation_filepath('t_temp11');
SHOW data_directory;

-- ID обслуживающего процесса
SELECT pg_backend_pid();
