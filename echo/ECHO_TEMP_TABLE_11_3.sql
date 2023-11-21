\echo -- Сессия оборвана
-- Сессия оборвана
\echo SELECT 1;
SELECT 1;
\echo -- Но сразу восстанавливается
-- Но сразу восстанавливается
\echo SELECT 1;
SELECT 1;

\echo SHOW remove_temp_files_after_crash;
SHOW remove_temp_files_after_crash;
\echo -- Отключаем параметр  remove_temp_files_after_crash в сессии нельзя
-- Отключаем параметр  remove_temp_files_after_crash в сессии нельзя
\echo SET remove_temp_files_after_crash = off;
SET remove_temp_files_after_crash = off;
\echo ALTER SYSTEM SET remove_temp_files_after_crash = off;
ALTER SYSTEM SET remove_temp_files_after_crash = off;

\echo -- Далее перезапускаем экземпляр
-- Далее перезапускаем экземпляр
