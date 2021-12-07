# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

<details><summary>.</summary>

> Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
> 
> Подключитесь к БД PostgreSQL используя `psql`.
> 
> Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
> 
> **Найдите и приведите** управляющие команды для:
> - вывода списка БД
> - подключения к БД
> - вывода списка таблиц
> - вывода описания содержимого таблиц
> - выхода из psql

</details>

**Найдите и приведите** управляющие команды для:

### вывода списка БД

```sql
  \l[+]   [PATTERN]      list databases
```

### подключения к БД

```sql
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
```

### вывода списка таблиц

```sql
  \dt[S+] [PATTERN]      list tables
```

### вывода описания содержимого таблиц

```
  \d[S+]  NAME           describe table, view, sequence, or index
```

### выхода из psql

```
  \q                     quit psql
```

## Задача 2

<details><summary>.</summary>

> Используя `psql` создайте БД `test_database`.
> 
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
> 
> Восстановите бэкап БД в `test_database`.
> 
> Перейдите в управляющую консоль `psql` внутри контейнера.
> 
> Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
> 
> Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.
> 
> **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

</details>

### Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах. **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' order by avg_width desc limit 1;
-[ RECORD 1 ]----
attname   | title
avg_width | 16
```

## Задача 3

<details><summary>.</summary>

> Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
> 
> Предложите SQL-транзакцию для проведения данной операции.
> 
> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

</details>

## Задача 4

<details><summary>.</summary>

> Используя утилиту `pg_dump` создайте бекап БД `test_database`.
> 
> Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

</details>

### Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
export PGPASSWORD=netology && pg_dumpall -h localhost -U postgres > /media/backup/test_database_all_$(date --iso-8601=m | sed 's/://g; s/+/z/g').sql
```

### Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Я бы добавил свойство `UNIQUE`
```sql
--
    title character varying(80) NOT NULL UNIQUE,
--
```