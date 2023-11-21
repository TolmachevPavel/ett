-- 1. Временная таблица on commit {reserver|delete|drop}
-- ON COMMIT PRESERVE ROWS — строки в таблице сохраняются до конца сессии
-- ON COMMIT DROP — таблица удаляется после завершения транзакции
-- ON COMMIT DELETE ROWS — все строки таблицы будут удалены после фиксации транзакции

\echo CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;

\echo CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;

\echo CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;

\echo INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);

\echo INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);

\echo INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);

\echo SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_1;

\echo SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_2;

\echo SELECT count(*) FROM t_temp1_3;
SELECT count(*) FROM t_temp1_3;

\echo SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';

\echo DROP TABLE t_temp1_1;
DROP TABLE t_temp1_1;

\echo DROP TABLE t_temp1_2;
DROP TABLE t_temp1_2;

\echo BEGIN;
BEGIN;

\echo CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE t_temp1_1 (id integer) ON COMMIT PRESERVE ROWS;

\echo CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;
CREATE TEMP TABLE t_temp1_2 (id integer) ON COMMIT DELETE ROWS;

\echo CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;
CREATE TEMP TABLE t_temp1_3 (id integer) ON COMMIT DROP;

\echo INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_1 SELECT * FROM generate_series(1,1_000);

\echo INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_2 SELECT * FROM generate_series(1,1_000);

\echo INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);
INSERT INTO t_temp1_3 SELECT * FROM generate_series(1,1_000);

\echo SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';

\echo SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_1;

\echo SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_2;

\echo SELECT count(*) FROM t_temp1_3;
SELECT count(*) FROM t_temp1_3;

\echo COMMIT;
COMMIT;

\echo SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';
SELECT schemaname, tablename FROM pg_tables WHERE tablename like 't_temp1%';

\echo SELECT count(*) FROM t_temp1_1;
SELECT count(*) FROM t_temp1_1;

\echo SELECT count(*) FROM t_temp1_2;
SELECT count(*) FROM t_temp1_2;

\echo SELECT count(*) FROM t_temp1_3;
SELECT count(*) FROM t_temp1_3;
