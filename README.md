devops-netology
===============

# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

<details>
<summary>.</summary>

> Сценарий выполения задачи:
> 
> - создайте свой репозиторий на https://hub.docker.com;
> - выберете любой образ, который содержит веб-сервер Nginx;
> - создайте свой fork образа;
> - реализуйте функциональность:
> запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
> ```
> <html>
> <head>
> Hey, Netology
> </head>
> <body>
> <h1>I’m DevOps Engineer!</h1>
> </body>
> </html>
> ```
> Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

</details>

Ссылка на Docker образ https://hub.docker.com/r/runout/ntdevops53-task1-nginx

## Задача 2

<details>
<summary>Задание</summary>

> Посмотрите на сценарий ниже и ответьте на вопрос:
> "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"
> 
> Детально опишите и обоснуйте свой выбор.
> 
> --
> 
> Сценарий:
> 
> - Высоконагруженное монолитное java веб-приложение;
> - Nodejs веб-приложение;
> - Мобильное приложение c версиями для Android и iOS;
> - Шина данных на базе Apache Kafka;
> - Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
> - Мониторинг-стек на базе Prometheus и Grafana;
> - MongoDB, как основное хранилище данных для java-приложения;
> - Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

</details>

> Высоконагруженное монолитное java веб-приложение;

Зависит от того, может ли приложение масштабироваться и взаимодействовать с каким-нибудь балансировщиком. Если архитектура это позволяет - то контейнеры будут удобней виртуальных машин, т.к. они быстрей разворачиваются, менее требовательны к месту и прочим ресурсам.

Если в приложение не заложено масштабирование, тогда лучше физическая машина, чтобы не тратить лишние ресурсы на виртуализацию.

> Nodejs веб-приложение;

Докер подойдёт хорошо, т.к. это позволит быстро развернуть приложение со всеми необходимыми библиотеками. 

> Мобильное приложение c версиями для Android и iOS;

Скорей всего нет, т.к. я не нашел информации о какой-то интеграции инструментов разработки под мобильные платформы с Docker. 

Это могло бы пригодиться, например для автотестов и удобства разработки, чтобы поделиться билдом приложения с коллегами и запустить его без боли и так далее. 

[Есть](https://github.com/budtmo/docker-android) [разные](https://github.com/sickcodes/Docker-OSX) [проекты](https://github.com/sickcodes/Docker-eyeOS), посвящённые запуску эмуляторов и приложений для Android/iOS с использованием Docker.

Даже если это будет работать, как такие приложения поведут себя в реальной среде на ARM устройствах в интеграции с маркетами мобильных платформ - вопрос.

> Шина данных на базе Apache Kafka;

Да, вполне. Брокеры активно используются в современных распределённых приложениях, доставка приложения через докер на сервера и разработчикам в тестовую среду должна упростить жизнь. 

Ещё очень важно иметь возможность быстро откатиться если приложение обновили, и в продакшене что-то пошло не так. Докер будет особенно удобен чтобы "вернуть как было" один из центральных узлов приложения - шину.

> Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Docker подойдёт лучше, так как он будет удобней для кластеризации: у контейнеров меньше оверхед.

> Мониторинг-стек на базе Prometheus и Grafana;

Докер [подойдёт](https://grafana.com/blog/2019/05/07/ask-us-anything-should-i-run-prometheus-in-a-container/) для этой задачи хорошо. Разворвачивать node_exporter с Docker скорей всего не стоит, т.к. ему требуется прямой доступ к метрикам ядра, но Prometheus и Grafana можно использовать в Докере. 

> MongoDB, как основное хранилище данных для java-приложения;

Да, вполне подойдёт Docker. У MongoDB даже есть официальный образ на [Docker Hub](https://hub.docker.com/_/mongo). 

> Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

В общем случае, думаю удобней будет виртуальная машина, т.к. серверу GitLab не требуется масштабирование или деплой новой версии несколько раз в день, а виртуальная машина позволит очень удобно делать бекапы и при необходимости мигрировать её в кластере. 

Если в компании повсеместно используются контейнеры - тогда, может, будет удобней Docker, т.к. инженерам это будет привычней.


## Задача 3

<details>
<summary>.</summary>

> - Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
> - Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
> - Добавьте еще один файл в папку ```/data``` на хостовой машине;
> - Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

</details>

1. Запуск контейнеров

    ```bash
    vagrant@server1:~/netologydevops53/3$ docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
    934ca2651653e4669c5ce83ee1f37c78277d2bd80ba465f9148fb164a160f4d0
    vagrant@server1:~/netologydevops53/3$ docker run -it --rm -d --name debian -v $(pwd)/data:/data debian:stable
    c7444ead8f5c2508e8774b05e2867973fc8aac44800352f77c9f6c506aa904e9
    ```

2. Файл из контейнера с CentOS

    ```bash
    vagrant@server1:~/netologydevops53/3$ docker exec -it centos bash
    [root@934ca2651653 /]# echo "Hello Netology from CentOS!" > /data/centos.txt
    [root@934ca2651653 /]# exit
    ```

3. Файл с хоста

    ```bash
    vagrant@server1:~/netologydevops53/3$ echo "Hellow Netology from Host!" > data/host.txt
    ```
   
4. Файлы в директории `/data` в контейнере с Debian

    ```bash
    vagrant@server1:~/netologydevops53/3$ docker exec -it debian bash
    root@c7444ead8f5c:/# ls -l /data/
    total 8
    -rw-r--r-- 1 root root 28 Nov  6 12:01 centos.txt
    -rw-rw-r-- 1 1000 1000 27 Nov  6 12:02 host.txt
    ```

## Задача 4 (*)

<details>
<summary>.</summary>

> Воспроизвести практическую часть лекции самостоятельно.
> Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.
</details>

Ссылка на Docker Hub https://hub.docker.com/r/runout/ntdevops53-task4-ansible


# Прошлые ДЗ

<details>
<summary></summary>

## Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

<details>
<summary>Решение</summary> 

### Задача 1

> Опишите своими словами основные преимущества применения на практике IaaC паттернов.

- Копии конфигураций серверов всегда доступны в стороннем хранилище, если что-то случиться с сервером - бекап есть 
- Доступна история изменений, можно откатиться если что-то пошло не так
- Если нужно что-то уточнить о причинах или принятых решениях в конфигурации - известно к кому обращаться
- Удобно масштабировать
- Удобно вносить изменения - централизованно, через гит

> Какой из принципов IaaC является основополагающим?

Идемпотентность: возможность описать желаемое состояние того, что конфигурируется, с определённой гарантией что оно будет достигнуто.

### Задача 2

> Чем Ansible выгодно отличается от других систем управление конфигурациями?

- Если не удалось доставить конфигурацию на сервер, он оповестит об этом.
- Более простой синтаксис, чем, например, у Saltstack
- Работает без агента на клиентах, использует ssh для доступа на клиент

> Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Push надёжней, т.к. централизованно управляет конфигурацией и исключает ситуации, когда кто-то что-то исправил напрямую на сервере и не отразил в репозитории - это может потеряться или создавать непредсказуемые ситуации.

### Задача 3

> Установить на личный компьютер:
> 
> - VirtualBox
> - Vagrant
> - Ansible
> 
> *Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

Я постоянню использую WSL2, но его невозможно использовать вместе с VirtualBox, поэтому воспользовался Hyper-V из состава Windows 11 Pro, а Ansible буду использовать внутри виртуальной машины с ровиженером `ansible_local`

* Vagrant

      PS C:\Users\sergey> vagrant --version
      Vagrant 2.2.18

* Varantfile

      # -*- mode: ruby -*-
      # vi: set ft=ruby :
      
      Vagrant.configure("2") do |config|
          config.vm.box = "bento/ubuntu-20.04"
          config.vm.provider "hyperv"
          
          config.vm.network "public_network", bridge: "Default Switch"
          config.vm.synced_folder ".", "/vagrant", disabled: true
      
          config.vm.provider "hyperv" do |h|
              h.vm_integration_services = { 
                guest_service_interface: true
              }
          end
      
          config.vm.provision "shell", inline: <<-SHELL
            apt-get update
            apt-get install -y ansible
          SHELL
        end
               
* Ubuntu

      vagrant@ubuntu-20:~$ dmesg | grep 'Hypervisor detected'
      [    0.000000] Hypervisor detected: Microsoft Hyper-V

* Ansible

      vagrant@ubuntu-20:~$ ansible --version
      ansible 2.9.6
        config file = /etc/ansible/ansible.cfg
        configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
        ansible python module location = /usr/lib/python3/dist-packages/ansible
        executable location = /usr/bin/ansible
        python version = 3.8.2 (default, Apr 27 2020, 15:53:34) [GCC 9.3.0]

### Задача 4 (*). Воспроизвести практическую часть лекции самостоятельно.

> Создать виртуальную машину.
 
Пришлось модифицировать файлы из примера.

#### **Vagrantfile**

- Адаптировать опции ЦПУ, памяти и хостнейма для Hyper-V
- Изменить провиженер на `ansible_local`
- Изменить метод синхронизации папки на `rsync`
- Настроить сеть с провайдером Hyper-V пока невозможно, но т.к. используется `ansible_local`, для задачи это не критично


```ruby
ISO = "bento/ubuntu-20.04"
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "ansible/inventory"
servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ram => 1024,
    :core => 1,
    :bridge => "Hyper-V Internet"
  }
]

Vagrant.configure(2) do |config|
    config.vm.synced_folder ".", "/vagrant", type: "rsync", disabled: false
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = ISO
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", bridge: machine[:bridge], ip: machine[:ip]
            node.vm.provider "hyperv" do |h|
                h.enable_virtualization_extensions = true
                h.linked_clone = true
                h.vm_integration_services = { 
                    guest_service_interface: true
                }
                h.cpus = machine[:core]
                h.maxmemory = machine[:ram]
                h.vmname = machine[:hostname]
            end
            node.vm.provision "shell", inline: <<-SHELL
                apt-get update
                apt-get install -y ansible
                SHELL
            node.vm.provision "ansible_local" do |setup|
                setup.inventory_path = INVENTORY_PATH
                setup.playbook = "ansible/provision.yml"
                setup.become = true 
            end
        end
    end
end

```

#### **inventory**
- Изменился способ подключения на `ansible_connection=local`
```
[nodes:children]
manager

[manager]
server1.netology ansible_connection=local
```

#### **provision.yml**

- Заменил `hosts: nodes` на `hosts: all`. Пока нет опыта работы с Ansible, я не понял почему не работало с `nodes`, но с `all` заработало сразу.
- Убрал опции настройки ssh, т.к. сыпались некритичные ошибки, и они не нужны для `ansible_local`

```yaml
---

  - hosts: all
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker
```

> Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды `docker ps`

```shell
vagrant@server1:~$ sudo -i
root@server1:~# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
root@server1:~# docker -v
Docker version 20.10.10, build b485636
root@server1:~#
```

</details>

## Домашнее задание к занятию "5.1. Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения."

<details>

### Задача 1: Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.

Основная разница в необходимости модифицировать гостевые ОС:
* При аппаратной виртуализации она не требуется;
* Для паравиртуализации нужна модификация ядра и драйверов;
* При виртуализации средствами ОС, гостевая ОС не имеет собственного ядра, использует ядро хоста.

Ещё разница в производительности. Чем больше модифицирована ОС, тем производительность выше. Наиболее высокая у виртуализации средствами ОС, так как приложения напрямую используют ядро хостовой ОС.

### Задача 2: Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.

| Условия | Организация | Почему |
| --- | --- | --- |
| Высоконагруженная база данных, чувствительная к отказу | физические сервера | Виртуализация даёт оверхед и увеличивает латентность. В высоконагруженной системе это нежелательно, а достичь отказоустойчивости можно резервированием. Постоянно нагруженной системе потребуется максимум ресурсов хоста, присутствие соседей которые могут их отобрать тоже нежелательно.  |
| Различные web-приложения | виртуализация уровня ОС | Современная практика - разворачивать часто и много веб-приложений на одном хосте, при этом нужно обеспечить их изоляцию друг от друга. Виртуализация ОС подходит лучше всего, так свернуть приложение в контейнер и развернуть из него быстрей, чем делать это с виртуальными машинами с полноценной ОС и отдельным ядром. |
| Windows системы для использования бухгалтерским отделом | паравиртуализация | Виртуализация поможет системе быть более отказоустойчивой, из предложенных вариантов для Windows возможна только паравиртуализация. |
| Системы, выполняющие высокопроизводительные расчеты на GPU | виртуализация уровня ОС | виртуализация GPU может потребоваться в проектах с машинным обучением, из предложенных видов виртуализации для GPU возможна только виртуализация средствами ОС |

### Задача 3: Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

> 1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.

Подойдут Hyper-V, vSphere: они оба хорошо поддерживают виртуальные машины с Windows и Linux, имеют встроенные перечисленные возможности (балансировка, репликация, бекапы) и могут работать в кластере гипервизоров, что необходимо для работы 100 виртуальных машин. 

> 2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.

Лучше всего подойдёт Proxmox в режиме KVM: open source решение, хорошо поддерживает Windows гостей, имеет возможности по управлению сравнимые с платными гипервизорами.

> 3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры.

Hyper-V Server, максимально совместим т.к. от Microsoft, полностью бесплатен.

> 4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

Оптимальней всего будет LXD, т.к. содержит огромную библиотеку с разными дистрибутивами в большом количестве конфигураций в виде контейнеров. Версия 4 позволяет запускать ещё и виртуальные машины, что позволит тестить даже ПО, требующее собственное полноценное ядро. 

### Задача 4: Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

Если я правильно понимаю, имеется в виду ситуация, когда используется несколько гипервизоров одного типа (например, VMWare ESXi и KVM), или примерно одного (например, Xen паравиртуализация и hardware assisted виртуализация с KVM или VMWare).
Основная проблема, из которой вытекает всё остальное - нужно в Н раз больше усилий на изучение и поддержку одного и того же.  
- Б**о**льшие расходы на штат инженеров, чтобы закрыть потребность в экспертизе по используемым технологиям
- Больше заморочек с мониторингом 
- Если требуется интегрировать гипервизор с какими-то внешними системами - нужно делать отдельно для каждой платформы
- В нужный момент может не оказаться специалистов по технологии, с которой возникли проблемы
- Скорей всего будет сложно выбирать железо: одни вендоры поддерживают одно, другие другое, нужно больше тратиться на резерв, сложно взаимно заменять аппаратные компоненты
- 

Решения мне видятся предельно простые: нанять больше людей, купить больше поддержки у вендоров, и/или использовать какую-то абстрагирующую прослойку вроде OpenStack, чтобы решить хотя бы задачи по интеграции и унификации управления. Использовать тот гипервизор, где у нас меньше экспертизы или специалистов, для менее критичных ресурсов. 

Лучшее решение, конечно, мигрировать на одну платформу, но полагаю это может быть не всегда возможно: всегда есть какое-то легаси, которое лучше не трогать без надобности, или раньше было дорогое и платное решение, теперь бюджет только на опенсорс, или какие-то административные ограничения и т.д. Либо мы работаем в датацентре и тогда, скорей всего, поддержку множества гипервизоров от нас будут ожидать клиенты.

Если бы я выбирал, то делал бы максимально единообразную систему с минимумом разнообразия используемых технологий в основе.

Конечно, если речь идёт о среде, где используются как виртуальные машины, так и контейнеры, то это "стандарт отрасли". Он несёт все минусы, которые я перечислил выше, но это параллельно развивающиеся технологии, имеющие свою нишу, и часто требуется знать и применять как минимум один гипервизор 1/2 уровня и какую-то технологию виртуализации.

</details>

## Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

<details>

### 1. Мы выгрузили JSON, который получили через API запрос к нашему сервису. Нужно найти и исправить все ошибки, которые допускает наш сервис.

Исправлено три ошибки и одна под вопросом:

| Ошибка | Как должно быть | Почему | 
| --- | --- | --- | 
| `"elements" :[` | `"elements" : [` | [Должен быть](https://www.json.org/img/object.png) пробел между двоеточием и скобкой, открывающей массив. | 
| `"ip :` | `"ip" :` | У строки [должны быть](https://www.json.org/img/string.png) две кавычки - открывающая и закрывающая. |
| `71.78.22.43` | `"71.78.22.43"` | Это тоже строка, и строки должны быть в кавычках | 
| `"ip" : 7175` | ? | 7175 из десятичной формы можно перевести в адрес "0.0.28.7"; в данном случае, это скорей всего ошибка и адрес недописали. | 

Исправленный, валидный JSON:

```json
{ "info" : "Sample JSON output from our service\t",
    "elements" : [
        { "name" : "first",
        "type" : "server",
        "ip" : 7175 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```

### 2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

```python
#!/usr/bin/env python3

import socket
import time
import json
import yaml
import time

hosts = {"drive.google.com": "192.168.0.1",
         "mail.google.com": "172.16.0.1", "google.com": "10.0.0.1"}

while True:
    try:
        with open('./services.json', 'r+') as config_json, open('./services.yaml', 'r+') as config_yaml:
            try:
                hosts_json = json.load(config_json)
                print(f"Подгружен ./services.json")
            except json.decoder.JSONDecodeError as e:
                print(f"Файл ./services.json в неверном формате.")
                exit()
            try:
                hosts_yaml = hosts_yaml = yaml.load(
                    config_yaml.read(), Loader=yaml.SafeLoader)
                print(f"Подгружен ./services.yaml")
            except yaml.scanner.ScannerError as e:
                print(f"Файл ./services.yaml в неверном формате.")
                exit()
            if hosts_yaml != hosts_json:
                print(
                    f"""\nСписки хостов в json и yaml отличаются:\n\nyaml: {hosts_yaml}\njson: {hosts_json}\n\nУдалите один или исправьте вручную. Потом запустит скрипт заново.\n""")
                exit()
            else:
                try:
                    hosts = hosts_yaml
                    while True:
                        for host in hosts:
                            cur_ip = hosts[host]
                            check_ip = socket.gethostbyname(host)
                            if check_ip != cur_ip:
                                print(
                                    f"""[ERROR] {host} IP mismatch: {cur_ip} {check_ip}""")
                                hosts[host] = check_ip
                                with open("./services.json", 'w+') as write_json, open("./services.yaml", 'w+') as write_yaml:
                                    write_json.write(
                                        json.dumps(hosts, indent=4))
                                    write_yaml.write(
                                        yaml.dump(hosts, indent=4))
                            else:
                                print(f"""{host} - {cur_ip}""")
                        time.sleep(2)
                except KeyboardInterrupt:
                    config_json.close
                    config_json.close
                    break
    except FileNotFoundError as e:
        print(f'Нет файла {e.filename}, создаём ')
        config = open(e.filename, 'w+')
        if config.name.endswith('.json'):
            try:
                config_yaml = open('./services.yaml', 'r+').read()
                hosts_yaml = yaml.load(
                    config_yaml, Loader=yaml.SafeLoader)
                config.write(json.dumps(hosts_yaml, indent=4))
            except FileNotFoundError:
                config.write(json.dumps(hosts, indent=4))
            except:
                print('Упс, всё пошло не так')
                exit()
        elif config.name.endswith('yaml') or e.filename.endswith('yml'):
            try:
                config_json = open('./services.json', 'r+')
                hosts_json = json.load(
                    config_json)
                config.write(yaml.dump(hosts_json, indent=4))
            except FileNotFoundError:
                config.write(json.dumps(hosts, indent=4))
            except:
                print('Упс, всё пошло не так')
                exit()
        config.read()
```

## 3. Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой.

```python
#!/usr/bin/env python3.9

import yaml
import json
import sys


def check_formats(string):
    f = {}
    try:
        j = json.loads(string)
        f['json'] = "valid"
        y = yaml.safe_load(string)
        f['yaml'] = "json"
    except json.decoder.JSONDecodeError as e:
        try:
            y = yaml.safe_load(string)
            f['yaml'] = "valid"
            try:
                json.dumps(y)
                f['json'] = "yaml"
            except json.decoder.JSONDecodeError as e3:
                m3 = e3.args[0]
                print(m3)
                f['json'] = "err"
            except TypeError as e3:
                m3 = e3.args[0]
                if m3.endswith('not list'):
                    json.dumps(y)
                    f['json'] = "yaml"
        except (yaml.parser.ParserError, yaml.scanner.ScannerError) as e2:
            f['yaml'] = "err"
            f['json'] = "err"
    return f


def yaml_to_file(f_name, d, fmt):
    # print(f'yaml_to_file, fmt = {fmt}')
    if fmt == "yaml":
        stream = yaml.dump(d, indent=2)
    if fmt == "json":
        j = json.loads(d)
        stream = yaml.dump(j, indent=2)
    # print(f"write to: {f_name}\ndata:\n{stream}")
    with open(f_name, 'w') as file:
        file.write(stream)
    print(f'Файл {f_name} записан')


def json_to_file(f_name, d, fmt):
    # print(f'json_to_file, fmt = {fmt}')
    if fmt == "json":
        stream = json.dumps(json.loads(d), indent=4)
    if fmt == "yaml":
        y = yaml.safe_load(d)
        stream = json.dumps(y, indent=2)
    # print(f"write to: {f_name}\ndata:\n{stream}")
    with open(f_name, 'w') as file:
        file.write(stream)
    print(f'Файл {f_name} записан')


def except_pprint(l, c, p, d, ex):
    d = d.split('\n')
    print(f"""
Не получилось разобрать {ex} файл, парсер остановился на строке {l+1}, символ {c+1}.

{d[l]}
{' ' * c}^

Суть проблемы: {p}
""")


args = sys.argv
source_file, ext, name, converted_file = '', '', '', ''
try:
    source_file = args[1]
    ext = source_file.split('.')[-1]
    name = source_file.split(f'.{ext}')[0]
    print(f'Исходный файл {source_file}')
    if ext == 'json':
        converted_file = f'{name}.yaml'
    elif ext == 'yaml' or ext == 'yml':
        converted_file = f'{name}.json'
    else:
        print(f"""Расширение ".{ext}" не поддерживается.\nПожалуйста, укажите файл JSON или YAML""")
except IndexError:
    print('Укажите имя файла в формате JSON или YAML')
    exit()

with open(source_file, 'r', encoding='utf_8') as file:
    data = file.read()
formats = check_formats(data)

if ext == 'json':
    if formats['json'] == "valid":
        yaml_to_file(converted_file, data, 'json')
    elif formats['json'] == "yaml":
        print(f'Файл {source_file} имеет формат yaml, переписываем')
        json_to_file(source_file, data, 'yaml')
        yaml_to_file(converted_file, data, 'yaml')
    else:
        try:
            json.loads(data)
        except json.decoder.JSONDecodeError as e:
            except_pprint(e.lineno-1, e.colno-1, e.args[0], data, ext)
elif ext == 'yaml':
    if formats['yaml'] == "valid":
        json_to_file(converted_file, data, 'yaml')
    elif formats['yaml'] == "json":
        print(f'Файл {source_file} имеет формат json, переписываем')
        yaml_to_file(source_file, data, 'json')
        json_to_file(converted_file, data, 'json')
    else:
        try:
            yaml.safe_load(data)
        except yaml.parser.ParserError as e:
            except_pprint(e.problem_mark.line, e.problem_mark.column, e.problem, data, ext)
        except yaml.scanner.ScannerError as e:
            try:
                except_pprint(e.context_mark.line, e.context_mark.column, e.problem, data, ext)
            except AttributeError:
                except_pprint(e.problem_mark.line, e.problem_mark.column, e.problem, data, ext)


```

</details>

## Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

<details>

### 1. Есть скрипт...

#### Какое значение будет присвоено переменной c?

Переменная не будет даже объявлена, т.к. произойдёт ошибка `TypeError: unsupported operand type(s) for +: 'int' and 'str'`: Python не понимает, что мы ожидаем от сложения строки и числа. 

#### Как получить для переменной c значение 12?

`c = (a + int(b)) * int(b) * int(b)`

#### Как получить для переменной c значение 3?

`c = a + int(b)`

### 2. Исправить скрипт  

```python
#!/usr/bin/env python3

import os

path = "~/netology/sysadm-homeworks"
resolved_path = os.path.normpath(os.path.abspath(os.path.expanduser(os.path.expandvars(path))))
bash_command = [f"cd {resolved_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(resolved_path, prepare_result))
```

### 3. Доработать скрипт  

```python
#!/usr/bin/env python3

import os
import sys
import subprocess
import re

try:
    path = sys.argv[1]
except IndexError:
    path = "~/netology/sysadm-homeworks"

resolved_path = os.path.normpath(os.path.abspath(
    os.path.expanduser(os.path.expandvars(path))))

try:
    result_os = subprocess.Popen(["git", "status", "--porcelain"], stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, cwd=resolved_path, text=True).communicate()[0].split('\n')
except FileNotFoundError:
    print(
        f'Не могу найти папку {path}'
    )
    exit()

if result_os[0].find('fatal:') >= 0:
    print(
        f'В папке {resolved_path} нет git репозитория. Поищите в другой папке.')
    exit()

list = {"M": "modified", "R": "renamed", "\?": "untracked"}

for result in result_os:
    for element in list.keys():
        regexp = re.compile(r"^ *" + element + "{1,2} *")
        if regexp.search(result):
            prepare_result = re.sub(regexp, '', result).split(' -> ')
            if list[element] == 'renamed':
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[1])} <- {prepare_result[0]}')
            else:
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[0])}')


```

### 4. Написать скрипт  

```python
# /usr/bin/env python3

import socket
import time

hosts = {"drive.google.com": {"ipv4": "192.168.0.1"}, "mail.google.com": {
    "ipv4": "172.16.0.1"}, "google.com": {"ipv4": "10.0.0.1"}}

while True:
    for host in hosts.keys():
        cur_ip = hosts[host]["ipv4"]
        check_ip = socket.gethostbyname(host)
        if check_ip != cur_ip:
            print(f"""[ERROR] {host} IP mismatch: {cur_ip} {check_ip}""")
            hosts[host]["ipv4"] = check_ip
        else:
            print(f"""{host} - {cur_ip}""")
    time.sleep(2)
```

### 5. Дополнительное задание:  автоматизировать цепочку действий

```python
#!/usr/bin/env python3

import os
import subprocess
import sys
import time
import requests
import json
import re
from datetime import datetime


def git_exec(command):
    print(command)
    if command.find("git commit") >= 0:
        command_splitted = ["git", "commit", "-m"]
        command_splitted.append(command.split('git commit -m ')[1])
    else:
        command_splitted = command.split()
    command_e = subprocess.Popen(command_splitted, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, cwd=resolved_path, text=True)
    e = command_e.communicate()[0].split('\n')[0]
    if e.find('fatal:') >= 0:
        print(
            f'В папке {resolved_path} нет git репозитория. Поищите в другой папке.')
        exit()
    return e


token = ""
if token == "":
    print(f"""
\t!!! Задайте токе в теле скрипта, переменная "token" !!!

\thttps://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
""")
    exit()

try:
    if sys.argv[1]:
        message = " ".join(sys.argv[1:])
except IndexError:
    print(
        f"Введите сообщение для реквеста, например:\n\n\t{sys.argv[0]} поправил конфиг, была ошибка синтаксиса\n")
    exit()

path = "./"
resolved_path = os.path.normpath(os.path.abspath(
    os.path.expanduser(os.path.expandvars(path))))

try:
    origin_push_url = git_exec("git remote get-url --push origin")
except FileNotFoundError:
    print(
        f'Не могу найти папку {path}'
    )
    exit()

if origin_push_url.find('fatal:') >= 0:
    print(
        f'В папке {resolved_path} нет git репозитория. Поищите в другой папке.')
    exit()

gh_acc, gh_repo = re.split('git@github.com:|/|.git', origin_push_url)[1:3]

repo_url = f'https://api.github.com/repos/{gh_acc}/{gh_repo}'

headers = {"Authorization": f"token {token}",
           "Accept": "application/vnd.github.v3+json"}

git_status = subprocess.Popen(["git", "status", "--porcelain"], stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, cwd=resolved_path, text=True).communicate()[0].split('\n')

cur_time = datetime.now()
branch_name = f"""{datetime.strftime(cur_time, "%Y-%m-%d_%H%M%S")}-config-local-edit"""
date_commit_text = datetime.strftime(cur_time, "%Y-%m-%d %H:%M:%S")

# exit()
if len(git_status) > 1 or git_status[0] != '':
    git_exec(f"git checkout -b {branch_name}")
    git_exec(f"git add .")
    git_exec(f"git commit -m 'config local edit at {date_commit_text}'")
    git_exec(f"git push --set-upstream origin {branch_name}")
    r = requests.get(f"{repo_url}/branches/{branch_name}", headers=headers)
    git_exec(f"git checkout main")
    while r.status_code >= 300:
        r = requests.get(f"{repo_url}/branches/{branch_name}", headers=headers)
        print(f'Репозитой пока не создан. Ответ GitHub: {r}, {r.content}')
        time.sleep(1)
    payload = {"title": branch_name, "body": message,
               "head": branch_name, "base": "main"}
    r = requests.post(f"{repo_url}/pulls", headers=headers,
                      data=json.dumps(payload))
    if r.status_code >= 300:
        print(
            f"Что-то пошло не так! Ответ GitHub API на создание Pull Request: {r}\n\n{r.content}\n")
        exit()
    else:
        print(f'Ответ GitHub на создание Pull Request: {r}')
        git_exec(f"git branch -D {branch_name}")
    pull_req_merge_url = f"{r.json()['url']}/merge"
    payload = {"commit_title": f"MERGED {branch_name} into main"}
    r = requests.put(pull_req_merge_url, headers=headers,
                     data=json.dumps(payload))
    if r.status_code >= 300:
        print(
            f"Что-то пошло не так! Ответ GitHub API на мерж Pull Request: {r}\n\n{r.content}\n")
        exit()
    else:
        print(f'Ответ GitHub на мерж Pull Request: {r}')
        git_exec(f"git push origin -d {branch_name}")
        print(f'\nЗагружаем изменения main:\n')
        os.popen(f"cd {resolved_path} && git pull").read()
        print(f'\n')
```

</details>

## Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

<details>

### 1. Есть скрипт. Какие значения переменным c,d,e будут присвоены? Почему?

* `c=a+b` вернёт `a+b` т.к. `a` и `b` указаны без символа `$`, а символ `+` воспринимается как оператор только в арифметических операциях 
* `d=$a+$b` вернёт `1+2`, т.к. `a` и `b` указаны с символом `$` и будут восприняты как обращения к переменным
* `e=$(($a+$b))` вернёт `3`, т.к. конструкция ((..)) служит для арифметических операций

### 2. На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:

В скрипте была пропущена скобка в конструкции ((1=1)**)** и не хватало условия выхода "**else break**", когда сервис поднимется.

Ниже исправленный скрипт: 

```bash
while ((1==1))
do
curl -ss http://localhost:4757
if (($? != 0))
then
date >> curl.log
else 
break
fi
done
```

### 3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.

```bash
declare -i keep_checking=1
while (($keep_checking<=5))
do
    for host in 192.168.0.1 173.194.222.113 87.250.250.242; do 
        nc -zw1 $host 80
        echo $? $host `date` >> 4-01-3.log
    done
keep_checking+=1
sleep 1
done
```

### 4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается

```bash
declare -i keep_checking=1
while (($keep_checking==1))
do
    for host in 192.168.0.1 173.194.222.113 87.250.250.242; do 
        nc -zw1 $host 80
        if (($?==0))
        then 
            echo $? $host `date` >> 4-01-3.log
        else 
            echo $host >> error.log 
            keep_checking=0 
        fi
    done
sleep 1
done
```

### 5. Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

Надо создать файл `.git/hooks/commit-msg` и следать его исполняемым (`chmod +x`).

Содержимое:

```bash
#!/usr/bin/env bash 

format_validator=$(grep -c "\[[[:digit:]]*-[[:alpha:]]*-[[:digit:]]*-[[:alpha:]]*\] *" "$1")
symbol_count=$(cat "$1" | wc -m )

if [[ "$format_validator" -eq "0" ]]; then 
    echo "Commit message не соответствует формату: [номер-раздела-номер-лекции] сообщение"
    echo 
    echo "Commit message:"
    cat $1 | grep -v ^#
    echo
    exit 1
elif [[ "$symbol_count" -gt "30" ]]; then 
    echo "Длина commit message не должна привышать 30 символов. Получилось $symbol_count символов"
    echo 
    echo :"Commit message:"
    cat $1 | grep -v ^#
    echo
    exit 1
fi

exit 0
```

</details>

## Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"

<details>

### 1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.

![Скриншот Bitwarden в Chrome](media/sysadmin-39-bitwarden.png)

### 2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.

![Скриншот Bitwarden в Chrome](media/sysadmin-39-bitwarden-g-auth.png)

### 3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.

![Скриншот Bitwarden в Chrome](media/sysadmin-39-apache-ssl.png)

Всё по инструкции из презентации:

```
root@node4:~# ll /etc/apache2/sites-enabled/example.conf
lrwxrwxrwx 1 root root 31 Sep 27 19:07 /etc/apache2/sites-enabled/example.conf -> ../sites-available/example.conf
```
```
root@node4:~# cat /etc/apache2/sites-enabled/example.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
   ServerName example.com
   DocumentRoot /var/www/example.com
   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
</IfModule>
```
```
root@node4:~# cat /var/www/example.com/index.html
<h1>Hello Netology!</h1>
```
```
root@node4:~# openssl x509 -text -noout -in  /etc/ssl/certs/apache-selfsigned.crt | grep Subject:
        Subject: C = RU, ST = Moscow, L = Yekaterinburg, O = Company Name, OU = Org, CN = www.example.com
```

### 4. Проверьте на TLS уязвимости произвольный сайт в интернете.

Проверил лёгковесную версию Яндекса, есть несколько уязвимостей.
```
$ ./testssl.sh -U --sneaky https://ya.ru
...

 Testing vulnerabilities

 Heartbleed (CVE-2014-0160)                not vulnerable (OK), no heartbeat extension
 CCS (CVE-2014-0224)                       not vulnerable (OK)
 Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK)
 ROBOT                                     not vulnerable (OK)
 Secure Renegotiation (RFC 5746)           supported (OK)
 Secure Client-Initiated Renegotiation     not vulnerable (OK)
 CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
 BREACH (CVE-2013-3587)                    potentially NOT ok, "gzip" HTTP compression detected. - only supplied "/" tested
                                           Can be ignored for static pages or if no secrets in the page
 POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
 TLS_FALLBACK_SCSV (RFC 7507)              Check failed, unexpected result , run testssl.sh -Z --debug=1 and look at /tmp/testssl.g0AyUH/*tls_fallback_scsv.txt
 SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
 FREAK (CVE-2015-0204)                     not vulnerable (OK)
 DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
                                           make sure you don't use this certificate elsewhere with SSLv2 enabled services
                                           https://censys.io/ipv4?q=26EB381642B07A05F7CA935101FC6492F91F7F0721995A8E577EDFB6723EBD1F could help you to find out
 LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no DH key detected with <= TLS 1.2
 BEAST (CVE-2011-3389)                     TLS1: ECDHE-RSA-AES128-SHA AES128-SHA DES-CBC3-SHA
                                           VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
 LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
 Winshock (CVE-2014-6321), experimental    not vulnerable (OK)
 RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)


 Done 2021-09-28 21:54:16 [  52s] -->> 87.250.250.242:443 (ya.ru) <<--

```

### 5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.
 
Сделал ключ, скопировал на другой сервер:
```
root@Node2:~# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/netology_rsa
...
```
```
root@Node2:~# ssh-copy-id -i .ssh/netology_rsa root@10.0.8.2
```
Проверил, что работает:
```
root@Node2:~# ssh -i .ssh/netology_rsa root@10.0.8.2 'ls -l | head -n 2'
total 28
-rw-r--r-- 1 tcpdump tcpdump 23085 Sep 27 19:35 node4-100packets.pcap
```

### 6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

Переименовал
```
root@Node2:~# mv .ssh/netology_rsa .ssh/39-6-netology_rsa
root@Node2:~# mv .ssh/netology_rsa.pub .ssh/39-6-netology_rsa.pub
```
Конфиг
```
root@Node2:~# cat .ssh/config
Host node4
    Hostname 10.0.8.2
    IdentityFile /root/.ssh/39-6-netology_rsa
```
Проверил
```
root@Node2:~# ssh node4 'ls -lh | head -n 2'
total 28K
-rw-r--r-- 1 tcpdump tcpdump  23K Sep 27 19:35 node4-100packets.pcap
```

### 7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

```
root@node4:~# tcpdump -nnei any -c 100 -w node4-100packets.pcap
tcpdump: listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes
100 packets captured
106 packets received by filter
0 packets dropped by kernel
```

![Скриншот Bitwarden в Chrome](media/sysadmin-39-wireshark.png)

### 8*. Просканируйте хост scanme.nmap.org. Какие сервисы запущены?

Запущены ssh, web-сервер, сервер nping-echo. Открытый порт 31337 - что-то вроде [шутки](https://www.speedguide.net/port.php?port=31337) в среде ИБ, либо троян.
```
root@Node2:~# nmap scanme.nmap.org
Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-28 19:02 UTC
Nmap scan report for scanme.nmap.org (45.33.32.156)
Host is up (0.21s latency).
Other addresses for scanme.nmap.org (not scanned): 2600:3c01::f03c:91ff:fe18:bb2f
Not shown: 996 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
9929/tcp  open  nping-echo
31337/tcp open  Elite

Nmap done: 1 IP address (1 host up) scanned in 3.86 seconds
```

### 9*. Установите и настройте фаервол ufw на web-сервер из задания 3. Откройте доступ снаружи только к портам 22,80,443

+520 port, RIPv2 из прошлых лабораторных 

```
root@node4:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80,443/tcp (Apache Full)   ALLOW IN    Anywhere
520                        ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80,443/tcp (Apache Full (v6)) ALLOW IN    Anywhere (v6)
520 (v6)                   ALLOW IN    Anywhere (v6)
```

</details>

## Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

<details>

### 1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

```
route-views>show ip route 5.189.xx.xx
Routing entry for 5.189.0.0/17
  Known via "bgp 6447", distance 20, metric 0
  Tag 3267, type external
  Last update from 194.85.40.15 2d02h ago
  Routing Descriptor Blocks:
  * 194.85.40.15, from 194.85.40.15, 2d02h ago
      Route metric is 0, traffic share count is 1
      AS Hops 2
      Route tag 3267
      MPLS label: none
```

### 2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.

1. Модуль 

       echo "dummy" > /etc/modules-load.d/dummy.conf
       echo "options dummy numdummies=2" > /etc/modprobe.d/dummy.conf

2. Настройка интерфейса через `systemd`

       cat << "EOF" >> /etc/systemd/network/10-dummy0.netdev
       [NetDev]
       Name=dummy0
       Kind=dummy
       EOF
       cat << "EOF" >> /etc/systemd/network/20-dummy0.network
       [Match]
       Name=dummy0
       
       [Network]
       Address=10.0.8.1/24
       EOF

3. Рестарт сети

       # systemctl restart systemd-networkd

4. Добавлен маршрут, конфигурация через `netplan`

           ens4:
             optional: true
             addresses:
               - 10.0.0.3/24
             routes:
               - to: 10.0.4.0/24
                 via: 10.0.0.2

5. Таблица маршрутизации, в ней один статический маршрут, определить можно по метке `static`:

       root@Node2:~# ip r
       default via 192.168.255.1 dev bond0 proto dhcp src 192.168.255.15 metric 100
       10.0.0.0/24 dev ens4 proto kernel scope link src 10.0.0.3
       10.0.1.0/24 dev vlan1001 proto kernel scope link src 10.0.1.3
       10.0.4.0/24 via 10.0.0.2 dev ens4 proto static
       10.0.8.0/24 dev dummy0 proto kernel scope link src 10.0.8.1
       192.168.255.0/24 dev bond0 proto kernel scope link src 192.168.255.15
       192.168.255.1 dev bond0 proto dhcp scope link src 192.168.255.15 metric 100

       root@Node2:~# ip r | grep stat
       10.0.4.0/24 via 10.0.0.2 dev ens4 proto static

[1](https://unix.stackexchange.com/questions/513578/), [2](https://serverfault.com/questions/1029041/)

### 3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.

Порты TCP 
```
root@Node1:~# ss -tnlp
State     Recv-Q    Send-Q       Local Address:Port       Peer Address:Port   Process
LISTEN    0         4096         127.0.0.53%lo:53              0.0.0.0:*       users:(("systemd-resolve",pid=576,fd=13))
LISTEN    0         128                0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=1197,fd=3))
LISTEN    0         128                   [::]:22                 [::]:*       users:(("sshd",pid=1197,fd=4))
```
53 порт - это DNS.

22 порт - это SSH.

### 4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?

Порты UDP
```
root@Node1:~# ss -unap
State    Recv-Q   Send-Q           Local Address:Port      Peer Address:Port   Process
UNCONN   0        0                127.0.0.53%lo:53             0.0.0.0:*       users:(("systemd-resolve",pid=576,fd=12))
UNCONN   0        0          192.168.255.10%ens3:68             0.0.0.0:*       users:(("systemd-network",pid=1516,fd=26))
```
53 порт - так же DNS.

68 порт использует DHCP для отправки сообщений клиентам.

### 5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали. 

![Домашняя сеть](media/sysadmin-38-home-network.png)


### 6*. Установите Nginx, настройте в режиме балансировщика TCP или UDP.
1. Удалить стандартную настройку порта 80 и добавить файл для своей

       rm -f /etc/nginx/sites-enabled/default
       touch /etc/nginx/conf.d/balancer.conf

2. Конфиг `/etc/nginx/conf.d/balancer.conf`:

       upstream backendn_netology_lab {
           ip_hash;
           server 10.0.4.2;
           server 10.0.0.3;
       }
       
       server {
           listen 80;
       
           location / {
               proxy_pass http://backendn_netology_lab;
           }
       }

3. Включить днс, предварительно отключить `systemd-resolve`, он занимает 53 порт

       systemctl disable systemd-resolved.service
       systemctl stop systemd-resolved.service

4. Конфиг DNS proxy: `/etc/nginx/modules-enabled/60-netology-lab.conf`

       stream {
   
           upstream dns_servers {
               server 77.88.8.8:53;
               server 8.8.8.8:53;
           }
   
           server {
               listen 53 udp;
               listen 53; #tcp 
               proxy_pass dns_servers;
               proxy_responses 1;
               proxy_timeout 1s;
           }
   
       }

[2](http://nginx.org/en/docs/http/load_balancing.html),
[3](https://gist.github.com/zoilomora/f7d264cefbb589f3f1b1fc2cea2c844c),
[4.1](https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/),
[4.2](https://www.nginx.com/blog/load-balancing-dns-traffic-nginx-plus/)

### 7*. Установите bird2, настройте динамический протокол маршрутизации RIP.

Конфиг из презентации. Получилось:
* Нода 1

      root@Node1:~# ip r | grep bir
      10.0.2.0/24 dev dummy0 proto bird scope link metric 32 
      10.0.8.0/24 via 10.0.0.3 dev ens4 proto bird metric 32

* Нода 2

      root@Node2:~# ip r | grep bird
      10.0.2.0/24 via 10.0.0.2 dev ens4 proto bird metric 32
      10.0.8.0/24 dev dummy0 proto bird scope link metric 32

### 8*. Установите Netbox, создайте несколько IP префиксов, используя curl проверьте работу API.

1. Docker

       curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
       echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
       sudo apt-get update
       sudo apt-get install docker-ce docker-ce-cli containerd.io
       apt install docker-compose

2. Netbox

       git clone -b release https://github.com/netbox-community/netbox-docker.git
       cd netbox-docker
       tee docker-compose.override.yml <<EOF
       version: '3.4'
       services:
         netbox:
           ports:
             - 8000:8080
       EOF
       docker-compose pull
       docker-compose up

3. Запрос на создание префика с `curl` 

       curl -ss -X POST \
       -H "Authorization: Token 0123456789abcdef0123456789abcdef01234567" \
       -H "Content-Type: application/json" \
       -H "Accept: application/json; indent=4" \
       http://192.168.255.10:8000/api/ipam/prefixes/ \
       --data '{
           "prefix": "10.0.18.0/24"
       }' | jq .

4. Ответ

        root@Node2:~# curl -ss -X POST \
        > -H "Authorization: Token 0123456789abcdef0123456789abcdef01234567" \
        > -H "Content-Type: application/json" \
        > -H "Accept: application/json; indent=4" \
        > http://192.168.255.10:8000/api/ipam/prefixes/ \
        > --data '{
        >     "prefix": "10.0.18.0/24"
        > }' | jq .
        {
          "id": 2,
          "url": "http://192.168.255.10:8000/api/ipam/prefixes/2/",
          "display": "10.0.18.0/24",
          "family": {
            "value": 4,
            "label": "IPv4"
          },
          "prefix": "10.0.18.0/24",
          "site": null,
          "vrf": null,
          "tenant": null,
          "vlan": null,
          "status": {
            "value": "active",
            "label": "Active"
          },
          "role": null,
          "is_pool": false,
          "mark_utilized": false,
          "description": "",
          "tags": [],
          "custom_fields": {},
          "created": "2021-09-15",
          "last_updated": "2021-09-15T21:25:30.652751Z",
          "children": 0,
          "_depth": 0
        }

[1](https://docs.docker.com/engine/install/ubuntu/), 
[1](https://forums.docker.com/t/command-not-found-when-i-try-to-run-docker-compose/97183/3), 
[2](https://github.com/netbox-community/netbox-docker),
[3](https://netbox.readthedocs.io/en/stable/rest-api/overview/#creating-a-new-object)

</details>

## Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

<details>

### 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

Linux
 * `ip link show`
 * `ifconfig -a`

Windows 
 * `ipconfig /all`

### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

Протокол LLDP, открытая альтернатива проприетарному протоколу CDP от Cisco.

Пакет `lldpd`. 

Командой `lldpctl` можно посмотреть соседей. То же самое можно увидеть командой `lldpcli sh neigh`

`lldpcli sh stat sum` покажет общую статистику по всем интерфейсам: переданные, полученные пакеты и тд.

`lldpcli sh int` покажет информацию по интерфейсам, на которых запущен lldpd.


### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

Технология называется VLAN (Virtual LAN).

Пакет в Ubuntu Linux так и называется, `vlan`

Пример конфига:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens4:
      optional: yes
      addresses: 
        - 10.0.0.2/24
  vlans:
    vlan1001:
      id: 1001
      link: ens4 
      addresses:
        - 10.0.1.2/24
```

### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

В Linux есть две технологии агрегации: bond и team. Изучил только первый.

Посмотреть какие типы агрегации предлает bond можно в информации о модуле ядра:
```
# modinfo bonding | grep mode:
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
```
Всего их семь. По типам их можно отнести к двум категориям:

Обеспечивают только фейловер, или фейловер и балансировку:
* `active-backup` и `broadcast` обеспечивают только отказоустойчивость
* `balance-tlb`, `balance-alb`, `balance-rr`, `balance-xor` и `802.3ad` обеспечат отказоустойчивость и балансировку

Можно настроить только с одной стороны, или потребуют настройки хоста и свича:
* `active-backup`, `balance-tlb` и `balance-alb` работают "сами по себе", можно настроить только на одном хосте
* `broadcast`,  `balance-rr`, `balance-xor` и `802.3ad` потребуют настройки ещё и коммутатора.

Рабочие конфиги:
* `active-backup` на отказоустойчивость:

       network:
         version: 2
         renderer: networkd
         ethernets:
           ens3:
             dhcp4: no 
             optional: true
           ens5: 
             dhcp4: no 
             optional: true
         bonds:
           bond0: 
             dhcp4: yes 
             interfaces:
               - ens3
               - ens5
             parameters:
               mode: active-backup
               primary: ens3
               mii-monitor-interval: 2

* `balance-alb`, балансировка

         bonds:
           bond0: 
             dhcp4: yes 
             interfaces:
               - ens3
               - ens5
             parameters:
               mode: balance-alb
               mii-monitor-interval: 2


### 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

В сети с маской 29 всего восемь адресов: использовать можно шесть, один адрес сети и один широковещательный адрес.

Сеть с маской /24 можно разбить на 32 подсети с маской /29.

Например:
* 10.10.10.7/29
* 10.10.10.48/29
* 10.10.10.184/29
* 10.10.10.232/29

### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

* Можно взять адреса из сети для CGNAT: `100.64.0.0/10`.
* Маска для диапазонов будет /26, она позволит подключить 62 хоста. 

### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

Проверить таблицу можно так:
* Linux: `ip neigh`, `arp -n`
* Windows: `arp -a`

Очистить кеш так:
* Linux: `ip neigh flush`
* Windows: `arp -d *`

Удалить один IP так:
* Linux: `ip neigh delete <IP> dev <INTERFACE>`, `arp -d <IP>`
* Windows: `arp -d <IP>`

### 8. Установите эмулятор EVE-ng.

![Скриншот Eve-NG с лабораторной](media/sysadmin-37-eve-ng.png)

</details>

## Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

<details>

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

</details>