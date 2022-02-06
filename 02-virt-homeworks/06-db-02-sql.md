devops-netology
===============

# Домашнее задание к занятию "6.2. SQL"

## Задача 1

<details><summary>.</summary>

> Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
> в который будут складываться данные БД и бэкапы.
> 
> Приведите получившуюся команду или docker-compose манифест.

</details>

`docker-compose.yaml`
```yaml
version: '3.6'

volumes:
  data: {}
  backup: {}

services:

  postgres:
    image: postgres:12
    container_name: psql
    ports:
      - "0.0.0.0:5432:5432"
    volumes:
      - data:/var/lib/postgresql/data
      - backup:/media/postgresql/backup
    environment:
      POSTGRES_USER: "test-admin-user"
      POSTGRES_PASSWORD: "netology"
      POSTGRES_DB: "test_db"
    restart: always
```
Старт
```bash
docker-compose up -d
export PGPASSWORD=netology && psql -h localhost -U test-admin-user test_db
```

## Задача 2

<details><summary>.</summary>

> В БД из задачи 1: 
> - создайте пользователя test-admin-user и БД test_db
> - в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
> - предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
> - создайте пользователя test-simple-user  
> - предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
> 
> Таблица orders:
> - id (serial primary key)
> - наименование (string)
> - цена (integer)
> 
> Таблица clients:
> - id (serial primary key)
> - фамилия (string)
> - страна проживания (string, index)
> - заказ (foreign key orders)
> 
> Приведите:
> - итоговый список БД после выполнения пунктов выше,
> - описание таблиц (describe)
> - SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
> - список пользователей с правами над таблицами test_db

</details>

### Итоговый список БД после выполнения пунктов выше

```
test_db=# \l
                                             List of databases
   Name    |      Owner      | Encoding |  Collate   |   Ctype    |            Access privileges
-----------+-----------------+----------+------------+------------+-----------------------------------------
 postgres  | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"test-admin-user"                   +
           |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user"
 template1 | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"test-admin-user"                   +
           |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user"
 test_db   | test-admin-user | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/"test-admin-user"                  +
           |                 |          |            |            | "test-admin-user"=CTc/"test-admin-user"
(4 rows)
```

### Описание таблиц (describe)

`clients`
```
test_db=# \d clients
                                         Table "public.clients"
      Column       |          Type          | Collation | Nullable |               Default
-------------------+------------------------+-----------+----------+-------------------------------------
 id                | integer                |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying(150) |           |          |
 страна проживания | character varying(150) |           |          |
 заказ             | integer                |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```
`orders`
```
test_db=# \d orders
                                       Table "public.orders"
    Column    |          Type          | Collation | Nullable |              Default
--------------+------------------------+-----------+----------+------------------------------------
 id           | integer                |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying(150) |           |          |
 цена         | integer                |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

### SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```sql
SELECT 
    grantee, table_name, privilege_type 
FROM 
    information_schema.table_privileges 
WHERE 
    grantee in ('test-admin-user','test-simple-user')
    and table_name in ('clients','orders')
order by 
    1,2,3;
```

### Список пользователей с правами над таблицами test_db

```
     grantee      | table_name | privilege_type
------------------+------------+----------------
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(22 rows)
```

## Задача 3

<details><summary>.</summary>

> Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:
> 
> Таблица orders
> 
> |Наименование|цена|
> |------------|----|
> |Шоколад| 10 |
> |Принтер| 3000 |
> |Книга| 500 |
> |Монитор| 7000|
> |Гитара| 4000|
> 
> Таблица clients
> 
> |ФИО|Страна проживания|
> |------------|----|
> |Иванов Иван Иванович| USA |
> |Петров Петр Петрович| Canada |
> |Иоганн Себастьян Бах| Japan |
> |Ронни Джеймс Дио| Russia|
> |Ritchie Blackmore| Russia|
> 
> Используя SQL синтаксис:
> - вычислите количество записей для каждой таблицы 
> - приведите в ответе:
>     - запросы 
>     - результаты их выполнения.

</details>

### Используя SQL синтаксис - наполните таблицы следующими тестовыми данными

`orders`
```
test_db=# select * from orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```
`clients`
```
test_db=# select * from clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |
  2 | Петров Петр Петрович | Canada            |
  3 | Иоганн Себастьян Бах | Japan             |
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
(5 rows)
```

### Вычислите количество записей для каждой таблицы, приведите в ответе: запросы, результаты их выполнения.

```sql
select count(*) from orders;
```
```
 count
-------
     5
(1 row)
```
```sql
select count(*) from clients;
```
```
 count
-------
     5
(1 row)
```

## Задача 4

<details><summary>.</summary>

> Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
> 
> Используя foreign keys свяжите записи из таблиц, согласно таблице:
> 
> |ФИО|Заказ|
> |------------|----|
> |Иванов Иван Иванович| Книга |
> |Петров Петр Петрович| Монитор |
> |Иоганн Себастьян Бах| Гитара |
> 
> Приведите SQL-запросы для выполнения данных операций.
> 
> Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
>  
> Подсказк - используйте директиву `UPDATE`.

</details>

### Приведите SQL-запросы для выполнения данных операций.

```sql
update clients set заказ = (select id from orders where наименование = 'Книга') where фамилия = 'Иванов Иван Иванович';
update clients set заказ = (select id from orders where наименование = 'Монитор') where фамилия = 'Петров Петр Петрович';
update clients set заказ = (select id from orders where наименование = 'Гитара') where фамилия = 'Иоганн Себастьян Бах';
```

### Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```sql
select c.* from clients c join orders o on c.заказ = o.id;
```
```
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

## Задача 5

<details><summary>.</summary>

> Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
> (используя директиву EXPLAIN).
> 
> Приведите получившийся результат и объясните что значат полученные значения.

</details>

```sql
test_db=# explain select c.* from clients c join orders o on c.заказ = o.id;
                              QUERY PLAN
-----------------------------------------------------------------------
 Hash Join  (cost=15.18..26.70 rows=120 width=644)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..11.20 rows=120 width=644)
   ->  Hash  (cost=12.30..12.30 rows=230 width=4)
         ->  Seq Scan on orders o  (cost=0.00..12.30 rows=230 width=4)
(5 rows)
```
1. Сначала будет полностью построчно прочитана таблица `orders` 
2. Для неё будет создан хэш по полю `id`
3. После будет прочитана таблица `clients`, 
4. Для каждой строки по полю `заказ` будет проверено, соответствует ли она чему-то в кеше `orders`
   - Если ничему не соответствует - строка будет пропущена
   - Если соответствует, то на основе этой строки и всех подходящих строках хеша СУБД сформирует вывод 

При запуске просто `explain`, Postgres напишет только примерный план выполнения запроса и для каждой операции предположит:
- сколько роцессорного времени уйдёт на поиск первой записи и сбор всей выборки: `cost`=`первая_запись`..`вся_выборка`
- сколько примерно будет строк: `rows`
- какой будет средняя длина строки в байтах: `width`

Postgres делает предположения на основе статистики, которую собирает периодический выполня `analyze` запросы на выборку данных из служебных таблиц.  

Если запустить `explain analyze`, то запрос будет выполнен и к плану добавятся уже точные данные по времени и объёму данных.

`explain verbose` и `explain analyze verbose` то для каждой операции выборки будут написаны поля таблиц, которые в выборку попали.

## Задача 6

<details><summary>.</summary>

> Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
> 
> Остановите контейнер с PostgreSQL (но не удаляйте volumes).
> 
> Поднимите новый пустой контейнер с PostgreSQL.
> 
> Восстановите БД test_db в новом контейнере.
> 
> Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

</details>

### Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

1. Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

   ```bash
   export PGPASSWORD=netology && pg_dumpall -h localhost -U test-admin-user > /media/postgresql/backup/all_$(date --iso-8601=m | sed 's/://g; s/+/z/g').sql
   ```

2. Остановите контейнер с PostgreSQL (но не удаляйте volumes).

   ```bash 
   $ docker-compose stop
   Stopping psql ... done
   $ docker ps -a
   CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS                     PORTS     NAMES
   213107257ce9   postgres:12   "docker-entrypoint.s…"   4 minutes ago   Exited (0) 2 seconds ago             psql
   ```

3. Поднимите новый пустой контейнер с PostgreSQL.

   ```bash
   docker run --rm -d -e POSTGRES_USER=test-admin-user -e POSTGRES_PASSWORD=netology -e POSTGRES_DB=test_db -v psql_backup:/media/postgresql/backup --name psql2 postgres:12
   ```
   ```bash
   CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                     PORTS      NAMES
   cf2c8f875948   postgres:12   "docker-entrypoint.s…"   4 minutes ago    Up 4 minutes               5432/tcp   psql2
   213107257ce9   postgres:12   "docker-entrypoint.s…"   14 minutes ago   Exited (0) 5 minutes ago              psql
   ```

4. Восстановите БД test_db в новом контейнере.

   ```bash
   docker exec -it psql2  bash
   export PGPASSWORD=netology && psql -h localhost -U test-admin-user -f $(ls -1trh /media/postgresql/backup/all_*.sql) test_db
   ```
