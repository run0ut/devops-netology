devops-netology
===============

# Домашнее задание к занятию "08.05 Тестирование Roles"

</details>  

## Подготовка к выполнению


<details><summary>.</summary>

1. Установите molecule: `pip3 install "molecule==3.4.0"`
    
    И чтобы работать с докером, модуль для этого тоже нужно установить:
    ```
    pip install --user "molecule[docker]"
    ```
2. Соберите локальный образ на основе [Dockerfile](./Dockerfile)

    Для этого потребуется регистрация аккаунта. У меня возникла проблема с его активацией (не приходило сообщение на почту) и я нашел такой способ, как получить образ:
    - [Тут](https://catalog.redhat.com/software/containers/search) найти [образ podman](https://catalog.redhat.com/software/containers/ubi8/podman/6113ec146e1e42ca4d6decca?q=podman&p=1). 
    Из него взять [докерфайл](https://catalog.redhat.com/software/containers/ubi8/podman/6113ec146e1e42ca4d6decca?q=podman&p=1&container-tabs=dockerfile) и заменить образ в основе на [этот](https://hub.docker.com/r/redhat/ubi8).
    Должно получиться так:
        ```Dockerfile
        # FROM registry.stage.redhat.io/ubi8/ubi:8.5
        FROM redhat/ubi8:8.5
        ...
    - Скачать два конфига и положить рядом
        `podman-containers.conf`
        ```ini
        [containers]
        volumes = [
                "/proc:/proc",
        ]
        ```
        `containers.conf`
        ```ini
        [containers]
        netns="host"
        userns="host"
        ipcns="host"
        utsns="host"
        cgroupns="host"
        cgroups="disabled"
        log_driver = "k8s-file"
        [engine]
        cgroup_manager = "cgroupfs"
        events_logger="file"
        runt
        ```
        Полный листинг докерфайла
        ```Dockerfile
        # FROM registry.stage.redhat.io/ubi8/ubi:8.5
        FROM redhat/ubi8:8.5
        LABEL maintainer="Red Hat, Inc."

        LABEL com.redhat.component="podman-container"
        LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"
        LABEL name="rhel8/podman"
        LABEL version="8.5"

        LABEL License="ASL 2.0"

        #labels for container catalog
        LABEL summary="Manage Pods, Containers and Container Images"
        LABEL description="podman (Pod Manager) is a fully featured container engine that is a simple daemonless tool. podman provides a Docker-CLI comparable command line that eases the transition from other container engines and allows the management of pods, containers and images.  Simply put: alias docker=podman.  Most podman commands can be run as a regular user, without requiring additional privileges. podman uses Buildah(1) internally to create container images. Both tools share image (not container) storage, hence each can use or manipulate images (but not containers) created by the other."
        LABEL io.k8s.display-name="Podman"
        LABEL io.openshift.expose-services=""

        # Don't include container-selinux and remove
        # directories used by yum that are just taking
        # up space.
        RUN dnf -y module enable container-tools:rhel8; dnf -y update; rpm --restore --quiet shadow-utils; \
        dnf -y install crun podman fuse-overlayfs /etc/containers/storage.conf --exclude container-selinux; \
        rm -rf /var/cache /var/log/dnf* /var/log/yum.*

        RUN useradd podman; \
        echo podman:10000:5000 > /etc/subuid; \
        echo podman:10000:5000 > /etc/subgid;

        VOLUME /var/lib/containers
        RUN mkdir -p /home/podman/.local/share/containers
        RUN chown podman:podman -R /home/podman
        VOLUME /home/podman/.local/share/containers

        # https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf
        ADD containers.conf /etc/containers/containers.conf
        # https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf
        ADD podman-containers.conf /home/podman/.config/containers/containers.conf

        # chmod containers.conf and adjust storage.conf to enable Fuse storage.
        RUN chmod 644 /etc/containers/containers.conf; sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
        RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock; touch /var/lib/shared/vfs-images/images.lock; touch /var/lib/shared/vfs-layers/layers.lock

        ENV _CONTAINERS_USERNS_CONFIGURED=""
        ```
    - Сбилдить
        ```bash
        docker build -t netology85-podman .
        ```
    - Поправить докерфайл из примера: вместо образа из реестра RHEL указать netology85-podman:
        ```Dockerfile
        # FROM registry.redhat.io/rhel8/podman:latest
        FROM netology85-podman:latest
        ENV MOLECULE_NO_LOG false

        RUN yum reinstall glibc-common -y
        RUN yum update -y && yum install tar gcc make python3-pip zlib-devel openssl-devel yum-utils libffi-devel -y

        ADD https://www.python.org/ftp/python/3.6.13/Python-3.6.13.tgz Python-3.6.13.tgz
        RUN tar xf Python-3.6.13.tgz && cd Python-3.6.13/ && ./configure && make && make altinstall
        ADD https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz Python-3.7.10.tgz
        RUN tar xf Python-3.7.10.tgz && cd Python-3.7.10/ && ./configure && make && make altinstall
        ADD https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz Python-3.8.8.tgz
        RUN tar xf Python-3.8.8.tgz && cd Python-3.8.8/ && ./configure && make && make altinstall
        ADD https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tgz Python-3.9.2.tgz
        RUN tar xf Python-3.9.2.tgz && cd Python-3.9.2/ && ./configure && make && make altinstall
        RUN python3 -m pip install --upgrade pip && pip3 install tox selinux
        RUN rm -rf Python-*
        ```
    - Сбилдить образ для теста Tox
        ```bash
        docker build -t netology85-tox:latest .
        ```

</details>  

## Основная часть


<details><summary>.</summary>


Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для kibana, logstash. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test` внутри корневой директории elasticsearch-role, посмотрите на вывод команды.

    <details><summary>log</summary>

    ```log
    INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun...
    INFO     Guessed /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible as project root directory
    WARNING  Computed fully qualified role name of elasticsearch_role does not follow current galaxy requirements.
    Please edit meta/main.yml and assure we can correctly determine full role name:

    galaxy_info:
    role_name: my_name  # if absent directory name hosting role is used instead
    namespace: my_galaxy_namespace  # if absent, author is used instead

    Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
    Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

    As an alternative, you can add 'role-name' to either skip_list or warn_list.

    INFO     Using /home/sergey/.cache/ansible-lint/8c7170/roles/elasticsearch_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/sergey/.cache/ansible-lint/8c7170/roles
    INFO     Running default > dependency
    WARNING  Skipping, missing the requirements file.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > lint
    INFO     Lint is disabled.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    INFO     Sanity checks: 'docker'
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    ok: [localhost] => (item=centos7)
    ok: [localhost] => (item=ubuntu)

    TASK [Delete docker networks(s)] ***********************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Running default > syntax
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    playbook: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/molecule/default/converge.yml
    INFO     Running default > create
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)
    skipping: [localhost] => (item=None)
    skipping: [localhost]

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7)
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest)

    TASK [Create docker network(s)] ************************************************

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    FAILED - RETRYING: Wait for instance(s) creation to complete (299 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '884224319527.97176', 'results_file': '/home/sergey/.ansible_async/884224319527.97176', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '321590610309.97204', 'results_file': '/home/sergey/.ansible_async/321590610309.97204', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include mnt-homeworks-ansible] *******************************************

    TASK [mnt-homeworks-ansible : Fail if unsupported system detected] *************
    skipping: [centos7]
    skipping: [ubuntu]

    TASK [mnt-homeworks-ansible : Check files directory exists] ********************
    ok: [centos7 -> localhost]

    TASK [mnt-homeworks-ansible : include_tasks] ***********************************
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/download_yum.yml for centos7
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/download_apt.yml for ubuntu

    TASK [mnt-homeworks-ansible : Download Elasticsearch's rpm] ********************
    ok: [centos7 -> localhost]

    TASK [mnt-homeworks-ansible : Copy Elasticsearch to managed node] **************
    changed: [centos7]

    TASK [mnt-homeworks-ansible : Download Elasticsearch's deb] ********************
    ok: [ubuntu -> localhost]

    TASK [mnt-homeworks-ansible : Copy Elasticsearch to manage host] ***************
    changed: [ubuntu]

    TASK [mnt-homeworks-ansible : include_tasks] ***********************************
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/install_yum.yml for centos7
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/install_apt.yml for ubuntu

    TASK [mnt-homeworks-ansible : Install Elasticsearch] ***************************
    changed: [centos7]

    TASK [mnt-homeworks-ansible : Install Elasticsearch] ***************************
    changed: [ubuntu]

    TASK [mnt-homeworks-ansible : Configure Elasticsearch] *************************
    changed: [ubuntu]
    changed: [centos7]

    RUNNING HANDLER [mnt-homeworks-ansible : restart Elasticsearch] ****************
    skipping: [centos7]
    skipping: [ubuntu]

    PLAY RECAP *********************************************************************
    centos7                    : ok=8    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    ubuntu                     : ok=7    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

    INFO     Running default > idempotence
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include mnt-homeworks-ansible] *******************************************

    TASK [mnt-homeworks-ansible : Fail if unsupported system detected] *************
    skipping: [centos7]
    skipping: [ubuntu]

    TASK [mnt-homeworks-ansible : Check files directory exists] ********************
    ok: [centos7 -> localhost]

    TASK [mnt-homeworks-ansible : include_tasks] ***********************************
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/download_yum.yml for centos7
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/download_apt.yml for ubuntu

    TASK [mnt-homeworks-ansible : Download Elasticsearch's rpm] ********************
    ok: [centos7 -> localhost]

    TASK [mnt-homeworks-ansible : Copy Elasticsearch to managed node] **************
    ok: [centos7]

    TASK [mnt-homeworks-ansible : Download Elasticsearch's deb] ********************
    ok: [ubuntu -> localhost]

    TASK [mnt-homeworks-ansible : Copy Elasticsearch to manage host] ***************
    ok: [ubuntu]

    TASK [mnt-homeworks-ansible : include_tasks] ***********************************
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/install_yum.yml for centos7
    included: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/mnt-homeworks-ansible/tasks/install_apt.yml for ubuntu

    TASK [mnt-homeworks-ansible : Install Elasticsearch] ***************************
    ok: [centos7]

    TASK [mnt-homeworks-ansible : Install Elasticsearch] ***************************
    ok: [ubuntu]

    TASK [mnt-homeworks-ansible : Configure Elasticsearch] *************************
    ok: [ubuntu]
    ok: [centos7]

    PLAY RECAP *********************************************************************
    centos7                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    ubuntu                     : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Verify] ******************************************************************

    TASK [Example assertion] *******************************************************
    ok: [centos7] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [ubuntu] => {
        "changed": false,
        "msg": "All assertions passed"
    }

    PLAY RECAP *********************************************************************
    centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=ubuntu)

    TASK [Delete docker networks(s)] ***********************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    ```

    </details>
    
2. Перейдите в каталог с ролью kibana-role и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.
    ```bash
    $ molecule init scenario --driver-name docker
    INFO     Initializing new scenario default...
    INFO     Initialized scenario in /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/kibana-role/molecule/default successfully.
    ```
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.


    ```yml
    ...
    platforms:
    - name: centos8
        image: docker.io/pycontribs/centos:8
        pre_build_image: true
    - name: ubuntu
        image: docker.io/pycontribs/ubuntu:latest
        pre_build_image: true
    - name: centos7
        image: docker.io/pycontribs/centos:7
        pre_build_image: true
    ...
    ```

    <details><summary>log</summary>

    ```log
    INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun...
    INFO     Guessed /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/kibana-role as project root directory
    WARNING  Computed fully qualified role name of kibana-role does not follow current galaxy requirements.
    Please edit meta/main.yml and assure we can correctly determine full role name:

    galaxy_info:
    role_name: my_name  # if absent directory name hosting role is used instead
    namespace: my_galaxy_namespace  # if absent, author is used instead

    Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
    Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

    As an alternative, you can add 'role-name' to either skip_list or warn_list.

    INFO     Using /home/sergey/.cache/ansible-lint/35620e/roles/kibana-role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Added ANSIBLE_ROLES_PATH=/home/sergey/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/sergey/.cache/ansible-lint/35620e/roles:/home/sergey/.cache/ansible-lint/35620e/roles
    INFO     Running default > dependency
    WARNING  Skipping, missing the requirements file.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > lint
    INFO     Lint is disabled.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    WARNING  Skipping, '--destroy=never' requested.
    INFO     Running default > syntax
    INFO     Sanity checks: 'docker'
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    playbook: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/kibana-role/molecule/default/converge.yml
    INFO     Running default > create
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)
    skipping: [localhost] => (item=None)
    skipping: [localhost] => (item=None)
    skipping: [localhost]

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 2, 'ansible_index_var': 'i'})

    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8)
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest)
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7)

    TASK [Create docker network(s)] ************************************************

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)
    changed: [localhost] => (item=centos7)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    FAILED - RETRYING: Wait for instance(s) creation to complete (299 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '814708959545.85679', 'results_file': '/home/sergey/.ansible_async/814708959545.85679', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '661203723398.85707', 'results_file': '/home/sergey/.ansible_async/661203723398.85707', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '269830497948.85736', 'results_file': '/home/sergey/.ansible_async/269830497948.85736', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [kibana-role : Download Kibana's rpm] *************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Install latest Kibana] *************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Configure Kibana] ******************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Get Kibana tar.gz] *****************************************
    ok: [centos7]
    ok: [ubuntu]
    ok: [centos8]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    changed: [ubuntu]
    changed: [centos7]
    changed: [centos8]

    TASK [kibana-role : Extract Kibana in the installation directory] **************
    changed: [centos8]
    changed: [ubuntu]
    changed: [centos7]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [centos7]
    changed: [ubuntu]
    changed: [centos8]

    TASK [kibana-role : Set environment Kibana] ************************************
    changed: [centos7]
    changed: [ubuntu]
    changed: [centos8]

    TASK [kibana-role : restart Kibana binary] *************************************
    ok: [centos7 -> 127.0.0.1]
    ok: [centos8 -> 127.0.0.1]
    ok: [ubuntu -> 127.0.0.1]

    PLAY RECAP *********************************************************************
    centos7                    : ok=7    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
    centos8                    : ok=7    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
    ubuntu                     : ok=7    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

    INFO     Running default > idempotence
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [kibana-role : Download Kibana's rpm] *************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Install latest Kibana] *************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Configure Kibana] ******************************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Get Kibana tar.gz] *****************************************
    ok: [centos8]
    ok: [centos7]
    ok: [ubuntu]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    ok: [ubuntu]
    ok: [centos7]
    ok: [centos8]

    TASK [kibana-role : Extract Kibana in the installation directory] **************
    skipping: [centos8]
    skipping: [centos7]
    skipping: [ubuntu]

    TASK [kibana-role : Configure Kibana] ******************************************
    ok: [centos7]
    ok: [centos8]
    ok: [ubuntu]

    TASK [kibana-role : Set environment Kibana] ************************************
    ok: [centos7]
    ok: [ubuntu]
    ok: [centos8]

    TASK [kibana-role : restart Kibana binary] *************************************
    ok: [centos8 -> 127.0.0.1]
    ok: [ubuntu -> 127.0.0.1]
    ok: [centos7 -> 127.0.0.1]

    PLAY RECAP *********************************************************************
    centos7                    : ok=6    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
    centos8                    : ok=6    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
    ubuntu                     : ok=6    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Verify] ******************************************************************

    TASK [Example assertion] *******************************************************
    ok: [ubuntu] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [centos8] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [centos7] => {
        "changed": false,
        "msg": "All assertions passed"
    }

    PLAY RECAP *********************************************************************
    centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    centos8                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    WARNING  Skipping, '--destroy=never' requested.
    ```

    </details>

4. Добавьте несколько assert'ов в verify.yml файл, для  проверки работоспособности kibana-role (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Повторите шаги 2-4 для filebeat-role.

    <details><summary>log</summary>

    ```log
    $ molecule test --destroy=never
    INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun...
    INFO     Guessed /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/filebeat-role as project root directory
    INFO     Running ansible-galaxy role install --force --roles-path /home/sergey/.cache/ansible-lint/fc12ac/roles -vr molecule/default/requirements.yml
    WARNING  Computed fully qualified role name of filebeat-role does not follow current galaxy requirements.
    Please edit meta/main.yml and assure we can correctly determine full role name:

    galaxy_info:
    role_name: my_name  # if absent directory name hosting role is used instead
    namespace: my_galaxy_namespace  # if absent, author is used instead

    Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
    Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

    As an alternative, you can add 'role-name' to either skip_list or warn_list.

    INFO     Using /home/sergey/.cache/ansible-lint/fc12ac/roles/filebeat-role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/sergey/.cache/ansible-lint/fc12ac/roles
    INFO     Running default > dependency
    Starting galaxy role install process
    - extracting kibana to /home/sergey/.cache/molecule/filebeat-role/default/roles/kibana
    - kibana (1.2.0) was installed successfully
    - extracting filebeat to /home/sergey/.cache/molecule/filebeat-role/default/roles/filebeat
    - filebeat (1.1.0) was installed successfully
    - extracting logstash to /home/sergey/.cache/molecule/filebeat-role/default/roles/logstash
    - logstash (1.1.0) was installed successfully
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > lint
    INFO     Lint is disabled.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    WARNING  Skipping, '--destroy=never' requested.
    INFO     Running default > syntax
    INFO     Sanity checks: 'docker'
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    playbook: /home/sergey/git/devops-netology/03-mnt-homeworks/08-ansible-05-testing/filebeat-role/molecule/default/converge.yml
    INFO     Running default > create
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)
    skipping: [localhost]

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item={'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']})

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item={'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']})

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})

    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7)

    TASK [Create docker network(s)] ************************************************

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item={'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']})

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=centos7)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '104872897240.57880', 'results_file': '/home/sergey/.ansible_async/104872897240.57880', 'changed': True, 'failed': False, 'item': {'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [centos7]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [centos7]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [centos7]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    changed: [centos7]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [centos7]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    changed: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    changed: [centos7]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    changed: [centos7]

    TASK [filebeat-role : restart Filebeat binary] *********************************
    ok: [centos7 -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [centos7]

    PLAY RECAP *********************************************************************
    centos7                    : ok=9    changed=4    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0

    INFO     Running default > idempotence
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [centos7]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [centos7]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [centos7]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    ok: [centos7]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [centos7]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    ok: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    ok: [centos7]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    ok: [centos7]

    TASK [filebeat-role : restart Filebeat binary] *********************************
    ok: [centos7 -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [centos7]

    PLAY RECAP *********************************************************************
    centos7                    : ok=9    changed=0    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Verify] ******************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos7]

    TASK [get elastic] *************************************************************

    TASK [elastic-role : Download Elasticsearch's rpm] *****************************
    skipping: [centos7]

    TASK [elastic-role : Install latest Elasticsearch] *****************************
    skipping: [centos7]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    skipping: [centos7]

    TASK [elastic-role : install iproute] ******************************************
    skipping: [centos7]

    TASK [elastic-role : Recollect facts] ******************************************
    skipping: [centos7]

    TASK [elastic-role : Get Elasticsearch tar.gz] *********************************
    ok: [centos7]

    TASK [elastic-role : Create directrory for Elasticsearch] **********************
    changed: [centos7]

    TASK [elastic-role : Extract Elasticsearch in the installation directory] ******
    changed: [centos7]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    changed: [centos7] => (item={'src': 'elasticsearch.yml.j2', 'dest': '/opt/elasticsearch/7.14.0/config/elasticsearch.yml'})
    changed: [centos7] => (item={'src': 'jvm.options.j2', 'dest': '/opt/elasticsearch/7.14.0/config/jvm.options'})

    TASK [elastic-role : Set environment Elasticsearch] ****************************
    changed: [centos7]

    TASK [elastic-role : Create group] *********************************************
    changed: [centos7]

    TASK [elastic-role : Create user] **********************************************
    changed: [centos7]

    TASK [elastic-role : Create directories] ***************************************
    changed: [centos7] => (item=/var/log/elasticsearch)
    ok: [centos7] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : Set permissions] ******************************************
    changed: [centos7] => (item=/var/log/elasticsearch)
    changed: [centos7] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : restart Elasticsearch binary] *****************************
    ok: [centos7 -> 127.0.0.1]

    TASK [get kibana] **************************************************************

    TASK [kibana-role : Download Kibana's rpm] *************************************
    skipping: [centos7]

    TASK [kibana-role : Install latest Kibana] *************************************
    skipping: [centos7]

    TASK [kibana-role : Configure Kibana] ******************************************
    skipping: [centos7]

    TASK [kibana-role : install iproute] *******************************************
    skipping: [centos7]

    TASK [kibana-role : Recollect facts] *******************************************
    skipping: [centos7]

    TASK [kibana-role : debug] *****************************************************
    skipping: [centos7]

    TASK [kibana-role : Get Kibana tar.gz] *****************************************
    ok: [centos7]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    changed: [centos7]

    TASK [kibana-role : Extract Kibana in the installation directory] **************
    changed: [centos7]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [centos7]

    TASK [kibana-role : Set environment Kibana] ************************************
    changed: [centos7]

    TASK [kibana-role : restart Kibana binary] *************************************
    ok: [centos7 -> 127.0.0.1]

    TASK [apply filebeat-role to setup kibana dashboards] **************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [centos7]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [centos7]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [centos7]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [centos7]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    ok: [centos7]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [centos7]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [centos7]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    ok: [centos7]

    TASK [filebeat-role : Enable and configure the system module] ******************
    ok: [centos7]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    ok: [centos7]

    TASK [filebeat-role : restart Filebeat binary] *********************************
    ok: [centos7 -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    FAILED - RETRYING: Load Kibana dashboards (3 retries left).
    ok: [centos7]

    TASK [test elastic web] ********************************************************
    ok: [centos7]

    TASK [test kibana web] *********************************************************
    ok: [centos7]

    TASK [check filebeat is running] ***********************************************
    ok: [centos7 -> 127.0.0.1]

    TASK [print what docker exec returned] *****************************************
    ok: [centos7] => {
        "msg": "filebeat process id = 3460"
    }

    TASK [check filebeat index exists] *********************************************
    ok: [centos7]

    TASK [checkif index not empty] *************************************************
    ok: [centos7] => {
        "msg": "number of documents in filebeat index = 353"
    }

    PLAY RECAP *********************************************************************
    centos7                    : ok=32   changed=12   unreachable=0    failed=0    skipped=18   rescued=0    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    WARNING  Skipping, '--destroy=never' requested.
    ```

    </details>

6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

    https://github.com/run0ut/filebeat-role/releases/tag/1.2.0

    https://github.com/run0ut/kibana-role/releases/tag/1.2.0

    https://github.com/run0ut/elastic-role/releases/tag/1.1.2

### Tox

1. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role -it <image_name> /bin/bash`, где path_to_repo - путь до корня репозитория с elasticsearch-role на вашей файловой системе.
2. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.
4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли.
7. Зайдти поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.
8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

    https://github.com/run0ut/kibana-role/releases/tag/1.3.0

    https://github.com/run0ut/filebeat-role/releases/tag/1.3.0

    https://github.com/run0ut/elastic-role/releases/tag/1.2.0

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

</details>  

8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Тестирование с Ansible 

    https://github.com/run0ut/filebeat-role/releases/tag/1.2.0

    https://github.com/run0ut/kibana-role/releases/tag/1.2.0

    https://github.com/run0ut/elastic-role/releases/tag/1.1.2

### Тестирование с Tox

    https://github.com/run0ut/kibana-role/releases/tag/1.3.0

    https://github.com/run0ut/filebeat-role/releases/tag/1.3.0

    https://github.com/run0ut/elastic-role/releases/tag/1.2.0

## Необязательная часть


<details><summary>.</summary>


1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечате адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои roles в репозитории. В ответ приведите ссылки.

