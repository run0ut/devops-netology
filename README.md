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

### Исправления с Гитхаба

Исправления внесены прямо в редакторе Гитхаба.


## Практика по занятию «2.3. Ветвления в Git»

Исправление в README, когда в соседней ветке он тоже изменён

C5
C6
C3
C8
C9
C4
C10

## Домашнее задание к занятию «2.4. Инструменты Git»

### 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

Полный хеш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545

```
$ git show aefea | head -n 1
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
```

### 2. Какому тегу соответствует коммит 85024d3?

Тегу v0.12.23

```
$ git tag -l --points-at 85024d3
v0.12.23
```

### 3. Сколько родителей у коммита b8d720? Напишите их хеши.

Два: 56cd7859e05c36c06b56d013b55a252d0bb7e158 и 9ea88f22fc6269854151c571162c5bcf958bee2b

```
$ git show --pretty=%P b8d720
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
```

### 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

Между тегами 10 коммитов. Хеши и комментарии:
```
$ git log v0.12.23..v0.12.24 --oneline
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
```

### 5. Найдите коммит в котором была создана функция func providerSource ...

Функция `func providerSource` была создана в коммите `8c928e8358` от 02.04.2020

```
$ git grep -n 'func providerSource(.*)'
provider_source.go:23:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
```

```
$ git log --oneline -S'func providerSource' provider_source.go
5af1e6234 main: Honor explicit provider_installation CLI config when present
8c928e835 main: Consult local directories as potential mirrors of providers
```

`$ git checkout 8c928e835`

```
git grep -n 'func providerSource(.*)'
provider_source.go:19:func providerSource(services *disco.Disco) getproviders.Source {
```

```
$ git blame -L 19,19 provider_source.go
8c928e8358 (Martin Atkins 2020-04-02 18:04:39 -0700 19) func providerSource(services *disco.Disco) getproviders.Source {
```

### 6. Найдите все коммиты в которых была изменена функция globalPluginDirs.

Функцию globalPluginDirs исправляли в пяти коммитах.

```
$ git grep 'func globalPluginDirs(.*)'
plugins.go:func globalPluginDirs() []string {
```
```
$ git log -L :globalPluginDirs:plugins.go  -s --oneline
78b122055 Remove config.go and update things using its aliases
52dbf9483 keep .terraform.d/plugins for discovery
41ab0aef7 Add missing OS_ARCH dir to global plugin paths
66ebff90c move some more plugin search path logic to command
8364383c3 Push plugin discovery down into command package
```

### 7. Кто автор функции synchronizedWriters?

Автор функции `synchronizedWriters` Martin Atkins. Он добавил её  `2017-05-03` коммитом `5ac311e2a`

Примерно в то же время, когда Андрей записывал курс, James Bardin удалил эту функцию коммитом `bdfea50cc` от `Mon Nov 30 18:02:04 2020` с комментарием `remove unused`.

```
$ git log -S'func synchronizedWriters' --oneline
bdfea50cc remove unused
5ac311e2a main: synchronize writes to VT100-faker on Windows
```
`git checkout 5ac311e2a`
``` 
$ git grep -n 'func synchronizedWriters(.*)'
synchronized_writers.go:15:func synchronizedWriters(targets ...io.Writer) []io.Writer {
```
```
$ git blame -L 15,15 synchronized_writers.go
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 15) func synchronizedWriters(targets ...io.Writer) []io.Writer {
```
## Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

### 8. Ознакомиться с разделами man bash
* Длина журнала задаётся переменой окружения `HISTSIZE`, она описана со строки `№982` и ниже.
* Директива `ignoreboth` "включает" сразу две: `ignorespace` и `ignoredups`. Если она задана, во-первых в историю не будут сохраняться команды, начинающиеся с пробела, во-вторых повторения команды подряд, например если ввести команду `ls -l`, потом снова ввести её, то вместо двух строк в историю запишется одна.

### 9. В каких сценариях использования применимы скобки `{}`

1. Строка мануала **№1187**, при работе с массивами.\
   Например `echo ${array[@]}` выведет все элементы массива `array` через пробел, а `echo ${#array[@]}` - количество элементов в массиве `array`.
1. Строка мануала **№1256**, чтобы "перебрать" варианты.\
   Например, команда `ls -l /etc/{shadow,group}` выведет параметры файлов `/etc/shadow` и `/etc/group`, а команда `echo bla{1,2,3}bla` выведет строку `bla1bla bla2bla bla3bla`
1. Строка мануала **№1334**, чтобы модифицировать строки/переменные и использовать в скриптах. Вообще, это большая тема: Shell Parameter Expansions, начинается со строки 1324.\
   Напирмер `test="12345"; echo ${test:1:3}` выведет три "234", а конструкция `SetSomeVar=${1:-1000}` задаст переменной `SetSomeVar` значение "1000", если скрипту не передали параметров.
1. Строка мануала **№3365**, при написании функций. Тело функции описывается как раз в фигурных скобках.

### 10. ...как создать однократным вызовом touch 100000 файлов?..
* 100000 - да:\
`touch file{1..100000}`
* 300000 - нет:
```
$ touch file{1..300000}
-bash: /usr/bin/touch: Argument list too long
```

### 11. Что делает конструкция `[[ -d /tmp ]]`

Проверяет, что `/tmp` существует и это директория (строка №2079)

### 12. ... в выводе type -a bash ... первым пунктом в списке: `/tmp/new_path_directory`

```
$ ln -s /usr/bin /tmp/new_path_directory
$ PATH=/tmp/new_path_directory:${PATH}
```

### 13. Чем отличается планирование команд с помощью `batch` и `at`?

* `at` выполняется строго по расписанию
* `batch` выполняется, когда позволит нагрузка на систему (load average упадёт ниже 1.5 или значения, заданного командой atd)