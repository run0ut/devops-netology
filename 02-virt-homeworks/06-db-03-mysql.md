devops-netology
===============

# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

<details><summary>.</summary>

> Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
> 
> Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
> восстановитесь из него.
> 
> Перейдите в управляющую консоль `mysql` внутри контейнера.
> 
> Используя команду `\h` получите список управляющих команд.
> 
> Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
> 
> Подключитесь к восстановленной БД и получите список таблиц из этой БД.
> 
> **Приведите в ответе** количество записей с `price` > 300.
> 
> В следующих заданиях мы будем продолжать работу с данным контейнером.

</details>

### Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```bash
docker run --rm --name my \
    -e MYSQL_DATABASE=test_db \
    -e MYSQL_ROOT_PASSWORD=netology \
    -v $PWD/backup:/media/mysql/backup \
    -v my_data:/var/lib/mysql \
    -v $PWD/config/conf.d:/etc/mysql/conf.d \
    -p 13306:3306 \
    -d mysql:8
```

### Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД

```sql
mysql> \s
...
Server version:         8.0.27 MySQL Community Server - GPL
...
```

### **Приведите в ответе** количество записей с `price` > 300.

```sql
mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

<details><summary>.</summary>

> Создайте пользователя test в БД c паролем test-pass, используя:
> - плагин авторизации mysql_native_password
> - срок истечения пароля - 180 дней 
> - количество попыток авторизации - 3 
> - максимальное количество запросов в час - 100
> - аттрибуты пользователя:
>     - Фамилия "Pretty"
>     - Имя "James"
> 
> Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
>     
> Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
> **приведите в ответе к задаче**.

</details>

### Создайте пользователя test в БД c паролем test-pass

```sql 
CREATE USER 'test'@'localhost' 
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_CONNECTIONS_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
    ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
```

### Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`

```sql
grant select on test_db.* to test;
```

### Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test`

```sql
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test';
+------+-----------+------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                      |
+------+-----------+------------------------------------------------+
| test | localhost | {"last_name": "Pretty", "first_name": "James"} |
+------+-----------+------------------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

<details><summary>.</summary>

> Установите профилирование `SET profiling = 1`.
> Изучите вывод профилирования команд `SHOW PROFILES;`.
> 
> Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
> 
> Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
> - на `MyISAM`
> - на `InnoDB`

</details>

### Исследуйте, какой `engine` используется в таблице БД `test_db`

Используется `InnoDB`

```sql
mysql> SELECT table_schema,table_name,engine FROM information_schema.tables WHERE table_schema = DATABASE();
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)
```

### Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**

Изменил сначала на `MyISAM`, потом вернул `InnoDB`:
```sql
set profiling = 1;
alter table orders engine = 'MyISAM';
alter table orders engine = 'InnoDB';
show profiles;
```
Вывод профайлера:
```
mysql> show profiles;
+----------+------------+--------------------------------------+
| Query_ID | Duration   | Query                                |
+----------+------------+--------------------------------------+
|        1 | 0.02436675 | alter table orders engine = 'MyISAM' |
|        2 | 0.02349825 | alter table orders engine = 'InnoDB' |
|        3 | 0.01897750 | alter table orders engine = 'MyISAM' |
|        4 | 0.02332425 | alter table orders engine = 'InnoDB' |
|        5 | 0.01927200 | alter table orders engine = 'MyISAM' |
|        6 | 0.02297425 | alter table orders engine = 'InnoDB' |
|        7 | 0.01822650 | alter table orders engine = 'MyISAM' |
|        8 | 0.02154475 | alter table orders engine = 'InnoDB' |
+----------+------------+--------------------------------------+
```
Первый раз результат примерно одинаковый, потом конвертация в `MyISAM` стала проходить быстрей.

## Задача 4 

<details><summary>.</summary>

> Изучите файл `my.cnf` в директории /etc/mysql.
> 
> Измените его согласно ТЗ (движок InnoDB):
> - Скорость IO важнее сохранности данных
> - Нужна компрессия таблиц для экономии места на диске
> - Размер буффера с незакомиченными транзакциями 1 Мб
> - Буффер кеширования 30% от ОЗУ
> - Размер файла логов операций 100 Мб
> 
> Приведите в ответе измененный файл `my.cnf`.

</details>

```sql
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

# Netology
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = ON
innodb_log_buffer_size = 1048576
innodb_buffer_pool_size = 1688207360
innodb_log_file_size = 104857600
```
* ОЗУ виртуалки = 2Гб
