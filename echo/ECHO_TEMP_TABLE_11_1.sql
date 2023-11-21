\echo -- 11. Параметр remove_temp_files_after_crash
-- 11. Параметр remove_temp_files_after_crash

\echo SHOW remove_temp_files_after_crash;
SHOW remove_temp_files_after_crash;
\echo -- Включаем параметр  remove_temp_files_after_crash в сессии нельзя
-- Включаем параметр  remove_temp_files_after_crash в сессии нельзя
\echo SET remove_temp_files_after_crash = on;
SET remove_temp_files_after_crash = on;
\echo ALTER SYSTEM SET remove_temp_files_after_crash = on;
ALTER SYSTEM SET remove_temp_files_after_crash = on;

\echo -- Далее перезапускаем экземпляр
-- Далее перезапускаем экземпляр
