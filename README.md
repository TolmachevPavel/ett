# Experiments with temporary tables in PostgreSQL
## _Эксперименты с временными таблицами в PostgreSQL_

Данный материал появился в результате развития статьия на моём сайте [ptolmachev.ru](https://ptolmachev.ru/temp-table-odinnadcat-eksperimentov.html)

Я провёл одиннадцать экспериментов с временными таблицами в PostgreSQL 16-й версии, код и результаты которых привожу здесь.

## Список экспериментов:

1. Временная таблица on commit {reserver|delete|drop}
2. Временная таблица и путь поиска
3. Временное табличное пространство по умолчанию и нет
4. Временная таблица, представление и функция
5. Временная схема и суперпользователь
6. Временная схема и обычная роль
7. Auto {analyze|vacuum} временной и обычной таблицы
8. Параллельная обработка временных таблиц
9. Параметр temp_buffers
10. Временные таблица, индекс, TOAST и их расположение на диске
11. Параметр remove_temp_files_after_crash (тут возможно баг?)

Тут есть три директории:

- code
- results
- echo

## code

В него входят файлы вида 'TEMP_TABLE_N.sql', где N - это номер эксперимента.
Это sql-команды для выполнения эксперимента. Их можно скопировать в терминал по одной, либо пачкой.
Но рекомендованный способ выполнить команды - передать их в psql, например так:

`psql -f TEMP_TABLE_1.sql`

Или уже находясь в psql’e воспользоваться метакомандой \i:

`\i TEMP_TABLE_1.sql`

На выходе получите результат выполнения этих команд.

## results

В него входят файлы вида 'RESULT_TEMP_TABLE_N.sql', где N - это номер эксперимента.
Это сами команды экспериментов и их результат. Данные файлы не запускаются.

## echo

В него входят файлы вида 'ECHO_TEMP_TABLE_N.sql', где N - это номер эксперимента.
А это - команды (из директории `code`) с добавлением метакоманды \echo. 
С её помощью я получаю вывод для директории `results` - команды и их результат.
Для выполнения эти файлы нужно передать их в psql...

`psql -f TEMP_TABLE_1.sql`

...либо находясь в psql’e воспользоваться метакомандой \i:

`\i TEMP_TABLE_1.sql`
