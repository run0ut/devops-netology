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

