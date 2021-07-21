# devops-netology

Изменения для теста по заданию

Вот ещё изменения

> В файле `README.md` опишите своими словами какие файлы будут проигнорированы в будущем благодаря добавленному `.gitignore`.

Будет проигнорирован какой-то лог и какие-то служебные файлы, видимо типичные для Terraform (я пока не знаю что это).

## Уточнения по .gitignore Terraform 

```
## Local .terraform directories
**/.terraform/*
```
Исключит все папки с названием `.terraform` во всех вложенных папках и файлы в них.
То есть, например, `./terraform/projects/.terraform` и `./terraform/projects/main/.terraform` в индекс Гита не попадут, а `./terraform/.terraform` попадёт.

```
# .tfstate files
*.tfstate
*.tfstate.*
```
Исключит в этой папке все файлы с расширением `tfstate`, или в названии которых есть `.tfstate.`, например `test_file.tfstate.swp`

```
# Crash log files
crash.log
```
Исключит файл `crash.log` в этой директории (где лежит файл гитигнор)

```
# Exclude all .tfvars files, which are likely to contain sentitive data, such as
# password, private keys, and other secrets. These should not be part of version 
# control as they are data points which are potentially sensitive and subject 
# to change depending on the environment.
#
*.tfvars
```
Исключит все файлы с расширением `.tfvars` 


```
# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```
Исключит  файлы `override.tf` и `override.tf.json`, и прочие, которые заканчиваются на `_override.tf` и `_override.tf.json`, например `myfile_override.tf` и `myfile_override.tf.json` 

```
# Ignore CLI configuration files
.terraformrc
terraform.rc
```
Исключит два файла: `.terraformrc` и `terraform.rc` 

## Домашнее задание к занятию «2.2. Основы Git»

### Задание №4 – Упрощаем себе жизнь

> Попробуйте выполнить пару коммитов используя IDE.

Добавляем коммит

### Работа с временным бранчем

Добавлена строка в ветке fix

DDDD MAIN DDDD
DASDSADDAS 

### Исправления с Гитхаба

Исправления внесены прямо в редакторе Гитхаба.

11111 dasdasd

dasasdds


## Практика по занятию «2.3. Ветвления в Git»

Исправление в README, когда в соседней ветке он тоже изменён

dasdas
