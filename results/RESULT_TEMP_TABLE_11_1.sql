-- PSQL

-- 11. Параметр remove_temp_files_after_crash
-- 11_1
-- А здесь единым скриптом не получилось
-- Команды, начинающиеся с доллара — выполняются в ОС
 
SHOW remove_temp_files_after_crash;
 remove_temp_files_after_crash 
-------------------------------
 off
(1 row)
 
-- Включаем параметр remove_temp_files_after_crash в сессии нельзя
SET remove_temp_files_after_crash = on;
psql:11_1.sql:9: ERROR:  parameter "remove_temp_files_after_crash" cannot be changed now
 
ALTER SYSTEM SET remove_temp_files_after_crash = on;
ALTER SYSTEM
 
-- Далее перезапускаем экземпляр
 
-- 11.2
-- Проверяем параметр
 
SHOW remove_temp_files_after_crash;
 remove_temp_files_after_crash 
-------------------------------
 on
(1 row)
 
CREATE TEMP TABLE t_temp11 (id integer);
CREATE TABLE
 
INSERT INTO t_temp11 VALUES (1),(2),(3);
INSERT 0 3
 
SELECT pg_relation_filepath(t_temp11);
 pg_relation_filepath 
----------------------
 base/16391/t3_498992
(1 row)
 
SHOW data_directory;
       data_directory        
-----------------------------
 /var/lib/postgresql/16/main
(1 row)
 
-- ID обслуживающего процесса
 
SELECT pg_backend_pid();
 pg_backend_pid 
----------------
          77078
(1 row)

-- BASH

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	-rw-------  1 postgres postgres      8192 ноя 20 18:37 t3_498992

	$ sudo kill -9 77078

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	# пусто — таких файлов нет

-- PSQL

-- 11_3
-- Сессия оборвана
 
SELECT 1;
server closed the connection unexpectedly
    This probably means the server terminated abnormally
    before or while processing the request.
The connection to the server was lost. Attempting reset: Succeeded.
 
-- Но сразу восстанавливается
 
SELECT 1;
 ?column? 
----------
        1
(1 row)
 
SHOW remove_temp_files_after_crash;
 remove_temp_files_after_crash 
-------------------------------
 on
(1 row)
 
-- Отключаем параметр remove_temp_files_after_crash в сессии нельзя
 
SET remove_temp_files_after_crash = off;
psql:11_3.sql:15: ERROR:  parameter "remove_temp_files_after_crash" cannot be changed now
 
ALTER SYSTEM SET remove_temp_files_after_crash = off;
ALTER SYSTEM
 
-- Далее перезапускаем экземпляр

-- BASH

	$ sudo systemctl restart postgresql@16-main.service

-- PSQL

-- 11.2
-- Проверяем параметр
 
SHOW remove_temp_files_after_crash;
 remove_temp_files_after_crash 
-------------------------------
 off
(1 row)
 
CREATE TEMP TABLE t_temp11 (id integer);
CREATE TABLE
 
INSERT INTO t_temp11 VALUES (1),(2),(3);
INSERT 0 3
 
SELECT pg_relation_filepath(t_temp11);
 pg_relation_filepath 
----------------------
 base/16391/t3_507187
(1 row)
 
SHOW data_directory;
       data_directory        
-----------------------------
 /var/lib/postgresql/16/main
(1 row)
 
-- ID обслуживающего процесса
 
SELECT pg_backend_pid();
 pg_backend_pid 
----------------
          78040
(1 row)

-- BASH

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	-rw-------  1 postgres postgres      8192 ноя 20 18:37 t3_507187

	$ sudo kill -9 78040

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	-rw-------  1 postgres postgres      8192 ноя 20 18:37 t3_507187

	sudo hexdump /var/lib/postgresql/16/main/base/16391/t3_507187
	0000000 0000 0000 0000 0000 0000 0000 0000 0000
	*
	0002000

-- PSQL

-- Однако! Если опять подключиться к серверу
 
SELECT 1;
server closed the connection unexpectedly
    This probably means the server terminated abnormally
    before or while processing the request.
The connection to the server was lost. Attempting reset: Succeeded.
 
SELECT 1;
 ?column? 
----------
        1
(1 row)
 
-- Файлы временных таблиц будут удалены!

-- BASH

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	# пусто — файлов больше нет

-- PSQL

-- И еще раз однако!
-- 11.2
 
-- Проверяем параметр
 
SHOW remove_temp_files_after_crash;
 remove_temp_files_after_crash 
-------------------------------
 off
(1 row)
 
CREATE TEMP TABLE t_temp11 (id integer);
CREATE TABLE
 
INSERT INTO t_temp11 VALUES (1),(2),(3);
INSERT 0 3
 
SELECT pg_relation_filepath(t_temp11);
 pg_relation_filepath 
----------------------
 base/16391/t3_515379
(1 row)
 
SHOW data_directory;
       data_directory        
-----------------------------
 /var/lib/postgresql/16/main
(1 row)
 
-- ID обслуживающего процесса
SELECT pg_backend_pid();
 pg_backend_pid 
----------------
          78839
(1 row)

-- BASH (возможно тут?)

	$ sudo head -n 1 /var/lib/postgresql/16/main/postmaster.pid 
	78014

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	-rw-------  1 postgres postgres      8192 ноя 20 18:37 t3_507187

	$ sudo kill -9 78014

	$ sudo ls -al /var/lib/postgresql/16/main/base/16391/ | grep t3
	# иии пусто — файлов нет! Почему? Я подозреваю что это баг