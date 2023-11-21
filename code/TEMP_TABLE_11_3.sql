-- Сессия оборвана
SELECT 1;
-- Но сразу восстанавливается
SELECT 1;

SHOW remove_temp_files_after_crash;
-- Отключаем параметр  remove_temp_files_after_crash в сессии нельзя
SET remove_temp_files_after_crash = off;
ALTER SYSTEM SET remove_temp_files_after_crash = off;

-- Далее перезапускаем экземпляр

