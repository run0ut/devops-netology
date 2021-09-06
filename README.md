# devops-netology

## Домашнее задание к занятию «2.1. Системы контроля версий.»

<details>

Изменения для теста по заданию

Вот ещё изменения

> В файле `README.md` опишите своими словами какие файлы будут проигнорированы в будущем благодаря добавленному `.gitignore`.
****
Будет проигнорирован какой-то лог и какие-то служебные файлы, видимо типичные для Terraform (я пока не знаю что это).

### Уточнения по .gitignore Terraform 

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

</details>

## Домашнее задание к занятию «2.2. Основы Git»

<details>

### Задание №4 – Упрощаем себе жизнь

> Попробуйте выполнить пару коммитов используя IDE.

Добавляем коммит

### Работа с временным бранчем

Добавлена строка в ветке fix

### Исправления с Гитхаба

Исправления внесены прямо в редакторе Гитхаба.
</details>

## Домашнее задание к занятию «2.4. Инструменты Git»

<details>

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

</details>

## Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

<details>

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
  
        $ touch file{1..300000}
        -bash: /usr/bin/touch: Argument list too long

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
</details>

## Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"

<details>

### 1. Какого типа команда `cd`? 

Это встроенная команда оболочки:

```
$ type cd
cd is a shell builtin
```

Если бы это была отдельная программа, она бы меняла рабочую директорию только для себя, это бы не влияло на другие программы, запускающиеся от того же родительского процесса, что и сама cd.

### 2. Какая альтернатива без pipe команде `grep <some_string> <some_file> | wc -l`?

`wc -l < <(<some_string> <some_file>)`

### 3. Какой процесс с PID `1` является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?

`systemd`, об этом говорят `pstree` и `/proc`
```
$ pstree -a -p  | head -n 1
systemd,1
$ sudo ls -l /proc/1/exe
lrwxrwxrwx 1 root root 0 Aug  4 16:42 /proc/1/exe -> /usr/lib/systemd/systemd
```
Хотя `ps` говорит что это `init`, который по-сути симлинк на `systemd`
```
$ ps -F 1
UID          PID    PPID  C    SZ   RSS PSR STIME TTY      STAT   TIME CMD
root           1       0  0 41869 11436   0 13:11 ?        Ss     0:02 /sbin/init
$ ll /sbin/init
lrwxrwxrwx 1 root root 20 Jul 21 19:00 /sbin/init -> /lib/systemd/systemd*
```
Что забавно, пока не понимаю почему так.

### 4. Как будет выглядеть команда, которая перенаправит вывод stderr `ls` на другую сессию терминала?

В первую очередь, я подумал об этом:

`ll dsadaddsaasd 2>/proc/14368/fd/2`

Но вероятно имелось в виду что-то такое:

`ll dsadaddsaasd 2>/dev/pts/1`

### 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.

`sed 's/#/##/g' <~/.bashrc >testrc`

### 6. Получится ли вывести находясь в графическом режиме данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?

Да, например:

`echo 'message' > /dev/tty1`

Для этого нужно быть авторизованным на этом терминале. Или можно выполнить echo от root, тогда авторизоваться не обязательно.  

### 7. Выполните команду `bash 5>&1`. К чему она приведет? Что будет, если вы выполните `echo netology > /proc/$$/fd/5`? Почему так происходит?

`bash 5>&1` запустит экземпляр bash с дополнительным фаловым дескриптором "5" и перенаправит его на ф/д 1 (stdout).

`echo netology > /proc/$$/fd/5` выведет в терминал слово "netology". Это произойдёт потому что echo отправляет netology в файловый дескриптор с номером 5 текущего шела (подсистема /proc содержит информацию о запущенных процессах по их PID, $$ - подставит PID текущего шелла, в "папке" fd можно посмотреть на какие файлы ссылаются дескрипторы по номерам)  

### 8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty?

Да, например: 

`cat ~/.bashrc dasdsfad 2>&1 1>/dev/pts/0 | sed 's/cat/test/g' > test;`

### 9. Что выведет команда `cat /proc/$$/environ`? Как еще можно получить аналогичный по содержанию вывод?

Команда выведет набор переменных окружения, с которыми шелл был изначально вызван. 

Что-то похожее вернут команды `env -0`, запущенная без аргументов, и `printenv -0`. 

### 10. Используя `man`, опишите что доступно по адресам `/proc/<PID>/cmdline`, `/proc/<PID>/exe`.

`/proc/<PID>/cmdline` выведет команду, к которой относится <PID>, со всеми агрументами, разделёнными специальными символом '\x0' (это не пробел, cat файла выведёт всё "слипнувшимся")

`/proc/<PID>/exe` это симлинк на полный путь к исполняемому файлоу, из которого вызвана программа с этим пидом

### 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью `/proc/cpuinfo`.

SSE 4.2

```
$ cat /proc/cpuinfo  | grep -o 'sse[0-9_]*' | sort -h | uniq
sse
sse2
sse3
sse4_1
sse4_2
```

### 12. При открытии нового окна терминала и `vagrant ssh` создается новая сессия и выделяется pty. Однако ... not a tty ... Почитайте, почему так происходит, и как изменить поведение.

Это сделано для правильной работы в скриптах. Если сразу выполнить команду на удалённом сервере через ssh, sshd это поймёт, и запускаемые команды тоже, поэтому они не будут спрашивать что-то у пользователя, а вывод очистят от лишних данных.

Например, если в интерактивном режиме программа задала бы пользователю вопрос и ждала ответа "yes/no", при запуске через ssh она этого делать не станет.

Второй кейс -- это вывод. Если в интерактивной консоли вывод мог бы окраситься в разные цвета, то через ssh цвета не отправятся. Это важно, т.к. цвета по-сути реализуются символами, и если вывод использовать для переменных или направлять в файл, то скорей всего они будут мешаться.   

Изменить поведение можно добавив флаг `-t` при вызове ssh. 

[Источник](https://serverfault.com/questions/593399/what-is-the-benefit-of-not-allocating-a-terminal-in-ssh)

### 13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись `reptyr`.

Работает, делал по инструкции из [доки](https://github.com/nelhage/reptyr#typical-usage-pattern) проекта `reptyr`, правда не со screen, а tmux.

Ещё по документации потребловалось поменять настройку модуля YAML https://github.com/nelhage/reptyr#ptrace_scope-on-ubuntu-maverick-and-up, судя по [описанию](https://www.kernel.org/doc/html/v4.15/admin-guide/LSM/Yama.html), это не очень хорошо, так как может негативно влиять на безопасность системы.

### 14. Узнайте что делает команда `tee` и почему в отличие от `sudo echo` команда с `sudo tee` будет работать.

`tee` берёт что-то `stdin` и отправляет это в `stdout` или файл, а у `echo` есть только аргументы. которые она умеет отправлять только в `stdout`.

Ключевое отличие - `tee` умеет писать в файл, и если запустить её с повышенными привелегиями, то и доступ к файлу она будет иметь такой же, "повышенный".

В отличие от неё, вывод `echo` хоть и можно перенаправить, но само перенаправление делает родительский `shell`, и если у него нет рут-прав, то в "привелегированные" файлы писать не получится.    

Поэтому используется комбинация: `echo` отправляет что-то в `tee`, запущенный от `sudo`.

Источнии: [stackoverflow](https://stackoverflow.com/questions/82256/how-do-i-use-sudo-to-redirect-output-to-a-location-i-dont-have-permission-to-wr), `man tee`, `man echo`.

</details>

## Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

<details>

### 1. Какой системный вызов делает команда cd? Вам нужно найти тот единственный, который относится именно к cd.

chdir()

Можно убедиться, например, сравнив с набором вызовов какой-нибудь другой встроенной команды баша:

        $ diff <(strace /bin/bash -c 'cd /tmp' 2>&1 | cut -d'(' -f 1 | sort | uniq) <(strace /bin/bash -c 'alias' 2>&1 | cut -d'(' -f 1 | sort | uniq)
        4d3
        < chdir

### 2.  Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

`file` ищет файлы `magic.mgc` и `magic`, в двух местах:
* В домашней директории, скрытые
* В /etc

В Vagrant Ubuntu 20.04 оказался только файл `/etc/magic`

### 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof)... предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

1. По `pid` процесса, который держит файл, можно посмотреть его дескрипторы. 
1. В дескриптор эхнуть пустую строку, например: `echo '' > /proc/641740/fd/3`

### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Нет, судя по [Википедии](https://en.wikipedia.org/wiki/Zombie_process#Overview):
> When a process ends via exit, all of the memory and resources associated with it are deallocated so they can be used by other processes.

### 5. На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04.

914 разных путей, некоторые повторяются (один файл пытается найти в разных директориях):

```
# (timeout -k 1 -s 9 1 strace opensnoop-bpfcc 2>&1 | grep -E '^open|Killed' | sed 's|openat.*, "||g; s|", .*||g' ) | sort | uniq -c | sort -h | wc -l
914
```

В основном заголовочные файлы, какие-то файлы Python, библиотеки.

### 6. Какой системный вызов использует uname -a? 

Он называется так же, `uname()`

А получить то же самое из `/proc` можно так:
> Part of the utsname information is also accessible via /proc/sys/kernel/{ostype,  hostname,  osrelease, version, domainname}.

### 7. Чем отличается последовательность команд через ; и через && в bash? Есть ли смысл использовать в bash &&, если применить set -e?

Оба оператора нужны чтобы последовательно выполнить несколько команд. 
* `;` просто выполнит все команды последовательно, даже если какая-то завершится ошибкой.
* `&&` остановится, если какая-то команда в последовательности завершится ошибкой.

Судя по мануалу, скрипт с `set -e` не упадёт, если ошибкой завершится команда выполненная в конструкции с оператором && 

> The shell does not exit if the command that fails is part of the  command  list  immediately following  a  while or until keyword, part of the test following the if or elif reserved words, part of any command executed in a && or || list except the command following  the final && or || ...

Есть ли смысл использовать `&&` если задан `set -e`, не знаю, не могу придумать кейс, но такая возможность есть.  

### 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

* `errexit      same as -e` - скрипт завершится, если что-то в скрипте завершится ошибкой
* `nounset      same as -u` - скрипт завершится, если попытаться использовать незаданную переменную
* `xtrace       same as -x` - включит режим дебага
* `-o pipefail` - выведет последнюю корректно завершившуюся команду в пайплайне

Это очень удобно для отладки скриптов. `-x` детально покажет как скрипт работал, `-u` покажет, если не задана какая-то переменная, а `-e` в связке с `pipefail` помогут понять на какой команде скрипт упал.

### 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе.

Чтобы посчитать только первый символ, удобней оказалось использовать `state` вместо `stat`. 

```
$ ps -Ao state --cumulative k stat   | sort | uniq -c | sort -h
      1 R
     47 I
     57 S
```
В основном процессы находятся в состоянии ожидания.

</details>
           
## Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

<details>

### 1. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter
Установка 
```
cd /opt
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
sudo tar xzf node_exporter-1.2.2.linux-amd64.tar.gz
sudo rm -f node_exporter-1.2.2.linux-amd64.tar.gz
sudo touch node_exporter-1.2.2.linux-amd64/node_exporter.env
echo "EXTRA_OPTS=\"--log.level=info\"" | sudo tee node_exporter-1.2.2.linux-amd64/node_exporter.env
sudo mkdir -p /usr/local/lib/systemd/system/
sudo touch /usr/local/lib/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
```
unit-файл:
```
[Unit]
Description="Netology course node_exporer service file"

[Service]
EnvironmentFile=/opt/node_exporter-1.2.2.linux-amd64/node_exporter.env
ExecStart=/opt/node_exporter-1.2.2.linux-amd64/node_exporter $EXTRA_OPTS
StandardOutput=file:/var/log/node_explorer.log
StandardError=file:/var/log/node_explorer.log

[Install]
WantedBy=multi-user.target
```           
#### Предусмотрите возможность добавления опций к запускаемому процессу через внешний файл
Опции можно добавить через файл `/opt/node_exporter-1.2.2.linux-amd64/node_exporter.env`, в переменной `EXTRA_OPTS`
```
EXTRA_OPTS="--log.level=info"
```
#### Удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.
Похоже, стартует. Как показать, что автоматический пока не понимаю.
```
$ journalctl -u node_exporter.service
-- Logs begin at Wed 2021-08-04 16:42:43 UTC, end at Mon 2021-08-23 17:17:01 UTC. --
Aug 23 16:46:03 vagrant systemd[1]: Started "Netology course node_exporer service file".
Aug 23 17:02:45 vagrant systemd[1]: Stopping "Netology course node_exporer service file"...
Aug 23 17:02:45 vagrant systemd[1]: node_exporter.service: Succeeded.
Aug 23 17:02:45 vagrant systemd[1]: Stopped "Netology course node_exporer service file".
-- Reboot --
Aug 23 17:03:22 vagrant systemd[1]: Started "Netology course node_exporer service file".
```
### 2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

CPU: system,user покажут время, использованное системой и программами; steal - слишком высокий будет означать, что гипервизор перегружен и процессор занят другими ВМ; iowait - поможет отследить, всё ли в порядке с дисками и RAID.
```
node_cpu_seconds_total{cpu="0",mode="iowait"} 19.39
node_cpu_seconds_total{cpu="0",mode="steal"} 0
node_cpu_seconds_total{cpu="0",mode="system"} 4.46
node_cpu_seconds_total{cpu="0",mode="user"} 2.23
node_cpu_seconds_total{cpu="1",mode="iowait"} 21.99
node_cpu_seconds_total{cpu="1",mode="steal"} 0
node_cpu_seconds_total{cpu="1",mode="system"} 7.11
node_cpu_seconds_total{cpu="1",mode="user"} 0.98
```
MEM: MemTotal - количество памяти; MemFree и MemAvailable - сводобная и доступная (включая кеш) память; SwapTotal, SwapFree, SwapCached - своп, если слишком много занято -- памяти не хватает. 
``` 
node_memory_MemAvailable_bytes 7.7056e+08
node_memory_MemFree_bytes 7.11176192e+08
node_memory_MemTotal_bytes 1.028694016e+09
node_memory_SwapCached_bytes 0
node_memory_SwapFree_bytes 1.027600384e+09
node_memory_SwapTotal_bytes 1.027600384e+09
```
DISK: size_bytes и avail_bytes покажут объём и свободное место; readonly=1 может говорить о проблемах ФС, из-за чего она перешла в режим только для чтения; io_now - интенсивность работы с диском в текущий момент.
```
node_filesystem_avail_bytes{device="/dev/mapper/vgvagrant-root",fstype="ext4",mountpoint="/"} 6.0591689728e+10
node_filesystem_readonly{device="/dev/mapper/vgvagrant-root",fstype="ext4",mountpoint="/"} 0
node_filesystem_size_bytes{device="/dev/mapper/vgvagrant-root",fstype="ext4",mountpoint="/"} 6.5827115008e+10
node_disk_io_now{device="sda"} 0
```
NET: carrier_down, carrier_up - если много, значит что-то с кабелем; info - общая информация по нитерфейсу; mtu_bytes - может быть важно для диагностики потерь или если трафик хостов не проходит через маршрутизатор; receive_errs_total, transmit_errs_total, receive_packets_total, transmit_packets_total - ошибки передачи, в зависимости от объёма если больше процента, вероятно какие-то проблемы сети или с хостом
```
node_network_carrier_down_changes_total{device="eth0"} 1
node_network_carrier_up_changes_total{device="eth0"} 1
node_network_info{address="08:00:27:73:60:cf",broadcast="ff:ff:ff:ff:ff:ff",device="eth0",duplex="full",ifalias="",operstate="up"} 1
node_network_mtu_bytes{device="eth0"} 1500
node_network_receive_errs_total{device="eth0"} 0
node_network_receive_packets_total{device="eth0"} 4079
node_network_transmit_errs_total{device="eth0"} 0
node_network_transmit_packets_total{device="eth0"} 3567
```

### 3. Установите в свою виртуальную машину Netdata

* в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0

      $ grep -e bind -e web /etc/netdata/netdata.conf
      [web]
          web files owner = root
          web files group = netdata
          # bind to = localhost
          bind to = 0.0.0.0
* добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload

      >vagrant port
      The forwarded ports for the machine are listed below. Please note that
      these values may differ from values configured in the Vagrantfile if the
      provider supports automatic port collision detection and resolution.
      
          22 (guest) => 2222 (host)
       19999 (guest) => 19999 (host)

* После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на localhost:19999.

      $ sudo tcpdump -nni any port 19999 -c 4
      tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
      listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes
      19:09:49.207580 IP 10.0.2.2.1228 > 10.0.2.15.19999: Flags [.], seq 17742191:17743651, ack 2422691631, win 65535, length 1460
      19:09:49.207610 IP 10.0.2.15.19999 > 10.0.2.2.1228: Flags [.], ack 1460, win 65535, length 0
      19:09:49.208078 IP 10.0.2.2.1228 > 10.0.2.15.19999: Flags [.], seq 1460:4380, ack 1, win 65535, length 2920
      19:09:49.208078 IP 10.0.2.2.2094 > 10.0.2.15.19999: Flags [.], seq 51021862:51023322, ack 3464847156, win 65535, length 1460
      4 packets captured
      9 packets received by filter
      0 packets dropped by kernel

### 4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
Если это специально не скрывают, то да. Например, Vagrant в VirtualBox на Windows:
```
$ dmesg | grep -i 'Hypervisor detected'
[    0.000000] Hypervisor detected: KVM
```

### 5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?

`man proc` по параметру `/proc/sys/fs/nr_open` отсылает к лимиту `RLIMIT_NOFILE` в `man getrlimit`,
 он определяет: 
* максимальное количество файловых дескрипторов, которые может открыть процесс
* с версии ядра 4.5 ещё что-то связанное с `capabilities`, но я про них знаю только в общих чертах и не понял сути, что-то про ограничения для непривелигированных процессов по работе с unix-сокетами. 

По-умолчанию значение = 1048576

Текущее значение в системе можно посмотреть так: 
```
$ sysctl fs.nr_open
fs.nr_open = 1048576
```
Такого числа не позволит достичь `ulimit -n`:
```
$ ulimit --help | grep 'file desc'
      -n        the maximum number of open file descriptors
```
По-умолчанию оно равно 1024
```
$ ulimit -n
1024
```

### 6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.

Запущенные экземпляры bash
```
vagrant@vagrant:~$ ps au -H | fgrep '/bin/bash'| grep -v grep
vagrant     1681  0.0  0.4   9968  4136 pts/2    Ss   19:26   0:00 /bin/bash
root        1707  0.0  0.0   8080   592 pts/2    S    19:27   0:00       unshare -f --pid --mount-proc /bin/bash
root        1708  0.0  0.4   9836  4264 pts/2    S    19:27   0:00         /bin/bash
```
С `unshare` запущен bash PID = 1708. Если зайти в неймспейс по этому пиду, `ps aux -H` покажет, что PID bash = 1.
```
vagrant@vagrant:~$ sudo nsenter --target 1708 --pid --mount
root@vagrant:/# ps aux -H
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          24  0.0  0.3   9836  3976 pts/1    S    19:30   0:00 -bash
root          33  0.0  0.3  11492  3396 pts/1    R+   19:30   0:00   ps aux -H
root           1  0.0  0.4   9836  4264 pts/2    S    19:27   0:00 /bin/bash
root          12  0.0  0.0   8076   592 pts/2    S+   19:28   0:00   sleep 1h
```

### 7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине, после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

Это [fork-бомба](https://en.wikipedia.org/wiki/Fork_bomb), shell бесконечно создаёт новые экземпляры себя.

Стабилизировал виртуалку `cgroups`:
```
[ 1979.099127] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-10.scope
```
Чтобы изменить поведение, в файле `/usr/lib/systemd/system/user-.slice.d/10-defaults.conf` нужно поментья параметр `TasksMax` на больший процент, конкретное число или infinity, чтобы убрать лимит совсем. 

</details>

## Домашнее задание к занятию "3.5. Файловые системы"

<details>

### 1. Узнайте о sparse (разряженных) файлах.

Файлы с пустотами на диске. Записи пустот на диск не происходит, информация о них хранится только в метаданных.

### 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Нет, не могут, т.к. это просто ссылки на один и тот же inode - в нём и хранятся права доступа и имя владельца. 

### 3. Сделайте vagrant destroy на имеющийся инстанс Ubuntu.
Добавились диски `sdb` и `sdc`
```
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
sdc                    8:32   0  2.5G  0 disk
```

### 4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

```
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Command (m for help): F
Command (m for help): n
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.
```
```
Command (m for help): n
Select (default p): p
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.
```
```
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

### 5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.

```
vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb > sdb.dump
vagrant@vagrant:~$ sudo sfdisk /dev/sdc < sdb.dump
```

### 6. Соберите mdadm RAID1 на паре разделов 2 Гб.

```
root@vagrant:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
```

### 7. Соберите mdadm RAID0 на второй паре маленьких разделов.

```
root@vagrant:~# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]2
```

### 8. Создайте 2 независимых PV на получившихся md-устройствах. 

```
root@vagrant:~# pvcreate /dev/md0
root@vagrant:~# pvcreate /dev/md1
```
```
root@vagrant:~# pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0             lvm2 ---    <2.00g   <2.00g
  /dev/md1             lvm2 ---  1018.00m 1018.00m
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
```

### 9. Создайте общую volume-group на этих двух PV.

```
root@vagrant:~# vgcreate netology35 /dev/md0 /dev/md1
```
```
root@vagrant:~# vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  netology35   2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant    1   2   0 wz--n- <63.50g     0
```

### 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```
root@vagrant:~# lvcreate -L 100m -n n35-10-lv netology35 /dev/md1
```
```
root@vagrant:~# lvs -o +devices
  LV        VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  n35-10-lv netology35 -wi-a----- 100.00m                                                     /dev/md1(0)
  root      vgvagrant  -wi-ao---- <62.54g                                                     /dev/sda5(0)
  swap_1    vgvagrant  -wi-ao---- 980.00m                                                     /dev/sda5(16010)
```

### 11. Создайте mkfs.ext4 ФС на получившемся LV.

```
root@vagrant:~# mkfs.ext4 -L n35-11 -m 1 /dev/mapper/netology35-n35--10--lv
```
```
root@vagrant:~# blkid | grep n35
/dev/mapper/netology35-n35--10--lv: LABEL="n35-11" UUID="5b293916-8fc3-4065-89a0-17b8398b3531" TYPE="ext4"
```

### 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.

```
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount /dev/mapper/netology35-n35--10--lv /tmp/new/
root@vagrant:~# mount | grep n35
/dev/mapper/netology35-n35--10--lv on /tmp/new type ext4 (rw,relatime,stripe=256)
```

### 13. Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.

```
root@vagrant:~# cd /tmp/new/
root@vagrant:/tmp/new# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
```
```
root@vagrant:/tmp/new# ls -l
total 20508
drwx------ 2 root root    16384 Aug 24 19:02 lost+found
-rw-r--r-- 1 root root 20980365 Aug 19 04:09 test.gz
root@vagrant:/tmp/new# df -h /tmp/new/
Filesystem                          Size  Used Avail Use% Mounted on
/dev/mapper/netology35-n35--10--lv   93M   21M   70M  23% /tmp/new
```

### 14. Прикрепите вывод lsblk.

```
root@vagrant:/tmp/new# lsblk
NAME                         MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                            8:0    0   64G  0 disk
├─sda1                         8:1    0  512M  0 part  /boot/efi
├─sda2                         8:2    0    1K  0 part
└─sda5                         8:5    0 63.5G  0 part
  ├─vgvagrant-root           253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1         253:1    0  980M  0 lvm   [SWAP]
sdb                            8:16   0  2.5G  0 disk
├─sdb1                         8:17   0    2G  0 part
│ └─md0                        9:0    0    2G  0 raid1
└─sdb2                         8:18   0  511M  0 part
  └─md1                        9:1    0 1018M  0 raid0
    └─netology35-n35--10--lv 253:2    0  100M  0 lvm   /tmp/new
sdc                            8:32   0  2.5G  0 disk
├─sdc1                         8:33   0    2G  0 part
│ └─md0                        9:0    0    2G  0 raid1
└─sdc2                         8:34   0  511M  0 part
  └─md1                        9:1    0 1018M  0 raid0
    └─netology35-n35--10--lv 253:2    0  100M  0 lvm   /tmp/new
```

### 15. Протестируйте целостность файла:

```
root@vagrant:/tmp/new# gzip -t /tmp/new/test.gz
root@vagrant:/tmp/new# echo $?
0
```

### 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

```
root@vagrant:/tmp/new# pvmove -n n35-10-lv /dev/md1 /dev/md0
```
```
root@vagrant:/tmp/new# lvs -o +devices
  LV        VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  n35-10-lv netology35 -wi-ao---- 100.00m                                                     /dev/md0(0)
  root      vgvagrant  -wi-ao---- <62.54g                                                     /dev/sda5(0)
  swap_1    vgvagrant  -wi-ao---- 980.00m                                                     /dev/sda5(16010)
```

### 17. Сделайте --fail на устройство в вашем RAID1 md.

```
root@vagrant:/tmp/new# mdadm --fail /dev/md0 /dev/sdb1
```

### 18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.

```
root@vagrant:/tmp/new# dmesg | grep md0 | tail -n 2
[ 8609.034011] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

### 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

```
root@vagrant:/tmp/new# gzip -t /tmp/new/test.gz
root@vagrant:/tmp/new# echo $?
0
```

</details>

## Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

### 1. Работа c HTTP через телнет... В ответе укажите полученный HTTP код, что он означает?

В ответ пришел ответ 301: это редиект на другой URL, он указан в поле `location`. В даном случае, адрес тот же, но протокол HTTPS.

```
$ telnet stackoverflow.com 80
Trying 151.101.193.69...
Connected to stackoverflow.com.
Escape character is '^]'.
GET /questions HTTP/1.0
HOST: stackoverflow.com

HTTP/1.1 301 Moved Permanently
cache-control: no-cache, no-store, must-revalidate
location: https://stackoverflow.com/questions
x-request-guid: 4174fc6b-6ec5-4203-a0aa-87ca055a90d7
feature-policy: microphone 'none'; speaker 'none'
content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
Accept-Ranges: bytes
Date: Mon, 06 Sep 2021 18:12:25 GMT
Via: 1.1 varnish
Connection: close
X-Served-By: cache-fra19120-FRA
X-Cache: MISS
X-Cache-Hits: 0
X-Timer: S1630951946.793336,VS0,VE92
Vary: Fastly-SSL
X-DNS-Prefetch-Control: off
Set-Cookie: prov=e8fb6c09-96c2-035a-200c-2dc705fcc069; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

Connection closed by foreign host.
```

### 2. Повторите задание 1 в браузере, используя консоль разработчика F12.

#### укажите в ответе полученный HTTP код.

301, редирект

![Скриншот хедера в Firefox](media/sysadmin-35-headers.png)

#### проверьте время загрузки страницы, какой запрос обрабатывался дольше всего? приложите скриншот консоли браузера в ответ.

Страница загрузилась за 2.4с, самый долгий запрос - фавикон, 397мс.

![Скриншот таймлайна с ренжем по длительности](media/sysadmin-35-timeline.png)

### 3. Какой IP адрес у вас в интернете?

```
$ dig @resolver4.opendns.com myip.opendns.com +short
5.189.xx.xx
```

[источник](https://unix.stackexchange.com/questions/22615/how-can-i-get-my-external-ip-address-in-a-shell-script)

### 4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой `whois`

Адрес пренадлежит оператору "KomTehCentr"
```
$ whois 5.189.xx.x  | grep ^org-name
org-name:       LLC "KomTehCentr"
```
Номер AS: AS12668
```
$ whois 5.189.xx.xx  | grep ^origin
origin:         AS12668
```

### 5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой `traceroute`

Пакет проходит три AS: AS12668, AS8359, AS15169.
```
$ traceroute -An 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.27.112.1 [*]  0.167 ms  0.149 ms  0.178 ms
 2  192.168.1.1 [*]  0.976 ms  1.394 ms  0.733 ms
 3  5.189.7.1 [AS12668]  1.641 ms  1.996 ms  2.190 ms
 4  92.242.29.210 [AS12668]  4.515 ms  1.579 ms  4.034 ms
 5  212.188.22.34 [AS8359]  4.721 ms  4.978 ms  4.708 ms
 6  212.188.22.33 [AS8359]  2.354 ms  1.611 ms  1.782 ms
 7  212.188.29.249 [AS8359]  2.612 ms  2.194 ms  2.554 ms
 8  212.188.29.85 [AS8359]  18.152 ms  18.381 ms  17.945 ms
 9  195.34.50.161 [AS8359]  30.493 ms * *
10  212.188.29.82 [AS8359]  30.101 ms  30.093 ms  30.084 ms
11  108.170.250.83 [AS15169]  29.348 ms 108.170.250.34 [AS15169]  29.372 ms 108.170.250.113 [AS15169]  56.004 ms
12  * 142.251.49.158 [AS15169]  44.998 ms 209.85.255.136 [AS15169]  45.724 ms
13  216.239.48.224 [AS15169]  41.903 ms 108.170.235.204 [AS15169]  43.901 ms 74.125.253.94 [AS15169]  42.975 ms
14  172.253.51.223 [AS15169]  44.416 ms 172.253.79.169 [AS15169]  43.678 ms 142.250.208.25 [AS15169]  47.033 ms
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  * * *
22  * * *
23  * * *
24  8.8.8.8 [AS15169]  41.207 ms  40.209 ms *
```
AS принадлежат моему провайдеру, МТС и Google.
```
$ grep org-name <(whois AS12668)
org-name:       LLC "KomTehCentr"
$ grep org-name <(whois AS8359)
org-name:       MTS PJSC
$ grep OrgName <(whois AS15169)
OrgName:        Google LLC
```

### 6. Повторите задание 5 в утилите `mtr`. На каком участке наибольшая задержка - delay?

Дольше всех отвечает 14-ый хоп: `AS15169`  `216.239.63.65`

```
$ mtr 8.8.8.8 -znrc 1
Start: 2021-09-07T00:57:43+0500

HOST: Intel8086                   Loss%   Snt   Last   Avg  Best  Wrst StDev
  1. AS???    172.27.112.1         0.0%     1    0.2   0.2   0.2   0.2   0.0
  2. AS???    192.168.1.1          0.0%     1    0.6   0.6   0.6   0.6   0.0
  3. AS12668  5.189.7.1            0.0%     1    1.3   1.3   1.3   1.3   0.0
  4. AS12668  92.242.29.210        0.0%     1    1.7   1.7   1.7   1.7   0.0
  5. AS8359   212.188.22.34        0.0%     1    7.3   7.3   7.3   7.3   0.0
  6. AS8359   212.188.22.33        0.0%     1    2.0   2.0   2.0   2.0   0.0
  7. AS8359   212.188.29.249       0.0%     1    2.2   2.2   2.2   2.2   0.0
  8. AS8359   212.188.29.85        0.0%     1   18.4  18.4  18.4  18.4   0.0
  9. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 10. AS8359   212.188.29.82        0.0%     1   30.3  30.3  30.3  30.3   0.0
 11. AS15169  108.170.250.51       0.0%     1   25.8  25.8  25.8  25.8   0.0
 12. AS15169  142.251.49.158       0.0%     1   45.1  45.1  45.1  45.1   0.0
 13. AS15169  108.170.235.204      0.0%     1   43.3  43.3  43.3  43.3   0.0
 14. AS15169  216.239.63.65        0.0%     1   46.1  46.1  46.1  46.1   0.0
 15. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 16. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 17. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 18. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 19. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 20. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 21. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 22. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 23. AS???    ???                 100.0     1    0.0   0.0   0.0   0.0   0.0
 24. AS15169  8.8.8.8              0.0%     1   40.7  40.7  40.7  40.7   0.0
 ```

### 7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой `dig`

NS
```
$ dig +short NS dns.google
ns4.zdns.google.
ns3.zdns.google.
ns1.zdns.google.
ns2.zdns.google.
```
A
```
$ dig +short A dns.google
8.8.4.4
8.8.8.8
```

### 8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой `dig`
В обоих случаях `dns.google.`
```
$ for ip in `dig +short A dns.google`; do dig -x $ip | grep ^[0-9].*in-addr; done
8.8.8.8.in-addr.arpa.   0       IN      PTR     dns.google.
4.4.8.8.in-addr.arpa.   0       IN      PTR     dns.google.
```

