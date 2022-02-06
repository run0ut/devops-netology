devops-netology
===============

# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

> Опишите своими словами основные преимущества применения на практике IaaC паттернов.

- Копии конфигураций серверов всегда доступны в стороннем хранилище, если что-то случиться с сервером - бекап есть 
- Доступна история изменений, можно откатиться если что-то пошло не так
- Если нужно что-то уточнить о причинах или принятых решениях в конфигурации - известно к кому обращаться
- Удобно масштабировать
- Удобно вносить изменения - централизованно, через гит

> Какой из принципов IaaC является основополагающим?

Идемпотентность: возможность описать желаемое состояние того, что конфигурируется, с определённой гарантией что оно будет достигнуто.

## Задача 2

> Чем Ansible выгодно отличается от других систем управление конфигурациями?

- Если не удалось доставить конфигурацию на сервер, он оповестит об этом.
- Более простой синтаксис, чем, например, у Saltstack
- Работает без агента на клиентах, использует ssh для доступа на клиент

> Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

Push надёжней, т.к. централизованно управляет конфигурацией и исключает ситуации, когда кто-то что-то исправил напрямую на сервере и не отразил в репозитории - это может потеряться или создавать непредсказуемые ситуации.

## Задача 3

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

## Задача 4 (*). Воспроизвести практическую часть лекции самостоятельно.

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
