-- 11. Параметр remove_temp_files_after_crash

SHOW remove_temp_files_after_crash;

-- Включаем параметр  remove_temp_files_after_crash в сессии нельзя

SET remove_temp_files_after_crash = on;
ALTER SYSTEM SET remove_temp_files_after_crash = on;

-- Далее перезапускаем экземпляр