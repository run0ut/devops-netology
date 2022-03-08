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

### 8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Тестирование с Ansible 

- https://github.com/run0ut/filebeat-role/releases/tag/1.2.0
- https://github.com/run0ut/kibana-role/releases/tag/1.2.0

### Тестирование с Tox

- https://github.com/run0ut/kibana-role/releases/tag/1.3.0
- https://github.com/run0ut/filebeat-role/releases/tag/1.3.0

## Необязательная часть


<!-- <details><summary>.</summary> -->


1. Проделайте схожие манипуляции для создания роли logstash.

    Тестирование с `molecule` https://github.com/run0ut/logstash-role/releases/tag/1.2.1

    <details><summary>лог тестирования с molecule</summary>

    ```log
    $ molecule test -s default --destroy=never
    INFO     default scenario test matrix: dependency, destroy, create, converge, verify, destroy
    INFO     Performing prerun...
    INFO     Set ANSIBLE_LIBRARY=/home/sergey/.cache/ansible-compat/e51391/modules:/home/sergey/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
    INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/sergey/.cache/ansible-compat/e51391/collections:/home/sergey/.ansible/collections:/usr/share/ansible/collections
    INFO     Set ANSIBLE_ROLES_PATH=/home/sergey/.cache/ansible-compat/e51391/roles:/home/sergey/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
    INFO     Using /home/sergey/.ansible/roles/stopfailing.logstash_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Running default > dependency
    Starting galaxy role install process
    - extracting kibana to /home/sergey/.cache/molecule/logstash-role/default/roles/kibana
    - kibana (1.3.0) was installed successfully
    - extracting elastic to /home/sergey/.cache/molecule/logstash-role/default/roles/elastic
    - elastic (1.2.0) was installed successfully
    - extracting logstash to /home/sergey/.cache/molecule/logstash-role/default/roles/logstash
    - logstash (1.3.0) was installed successfully
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > destroy
    WARNING  Skipping, '--destroy=never' requested.
    INFO     Running default > create
    INFO     Sanity checks: 'docker'
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
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '673157685927.75433', 'results_file': '/home/sergey/.ansible_async/673157685927.75433', 'changed': True, 'failed': False, 'item': {'expoed_ports': ['5601/tcp', '9200/tcp'], 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True, 'published_ports': ['0.0.0.0:5601:5601/tcp', '0.0.0.0:9200:9200/tcp']}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > converge
    [DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the
    controller starting with Ansible 2.12. Current version: 3.7.3 (default, Jan 22
    2021, 20:04:44) [GCC 8.3.0]. This feature will be removed from ansible-core in
    version 2.12. Deprecation warnings can be disabled by setting
    deprecation_warnings=False in ansible.cfg.

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos7]

    TASK [Include logstash-role] ***************************************************

    TASK [logstash-role : Download Logstash's rpm] *********************************
    skipping: [centos7]

    TASK [logstash-role : Copy Logstash to manage host] ****************************
    skipping: [centos7]

    TASK [logstash-role : Ensure Java is installed.] *******************************
    skipping: [centos7]

    TASK [logstash-role : Install Logstash] ****************************************
    skipping: [centos7]

    TASK [logstash-role : Configure startup options] *******************************
    skipping: [centos7]

    TASK [logstash-role : Configure JVM options] ***********************************
    skipping: [centos7]

    TASK [logstash-role : Create startup scripts] **********************************
    skipping: [centos7]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    skipping: [centos7] => (item=simple_config.conf)

    TASK [logstash-role : install iproute] *****************************************
    skipping: [centos7]

    TASK [logstash-role : Recollect facts] *****************************************
    skipping: [centos7]

    TASK [logstash-role : debug] ***************************************************
    skipping: [centos7]

    TASK [logstash-role : Get Logstash tar.gz] *************************************
    ok: [centos7 -> localhost]

    TASK [logstash-role : Copy Logstash to manage host] ****************************

    changed: [centos7]

    TASK [logstash-role : Create directrory for Logstash] **************************
    changed: [centos7]

    TASK [logstash-role : Extract Logstash in the installation directory] **********
    changed: [centos7]

    TASK [logstash-role : Create java options directory] ***************************
    changed: [centos7] => (item=/opt/logstash/7.14.0/config/jvm.options.d)

    TASK [logstash-role : Configure JVM options] ***********************************
    changed: [centos7]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    changed: [centos7] => (item=simple_config.conf)
    changed: [centos7] => (item=pipelines.yml)
    changed: [centos7] => (item=startup.options)

    TASK [logstash-role : Set environment Logstash] ********************************
    changed: [centos7]

    TASK [logstash-role : try start Logstash binary in Docker] *********************
    ok: [centos7 -> 127.0.0.1]

    PLAY RECAP *********************************************************************
    centos7                    : ok=10   changed=7    unreachable=0    failed=0    skipped=11   rescued=0    ignored=0

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

    TASK [elastic-role : Recollect facts] ******************************************
    ok: [centos7]

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
    ok: [centos7 -> localhost]

    TASK [elastic-role : Copy Elasticsearch to manage host] ************************
    changed: [centos7]

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

    TASK [elastic-role : restart Elasticsearch binary on docker] *******************
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
    ok: [centos7 -> localhost]

    TASK [kibana-role : Copy Elasticsearch to manage host] *************************
    changed: [centos7]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    changed: [centos7]

    TASK [kibana-role : Extract Kibana in the installation directory] **************


    changed: [centos7]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [centos7]

    TASK [kibana-role : Set environment Kibana] ************************************
    changed: [centos7]

    TASK [kibana-role : try start Kibana binary in Docker] *************************
    ok: [centos7 -> 127.0.0.1]

    TASK [test elastic web] ********************************************************
    ok: [centos7]

    TASK [test kibana web] *********************************************************
    FAILED - RETRYING: test kibana web (10 retries left).
    ok: [centos7]

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
    ok: [centos7 -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    changed: [centos7]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    changed: [centos7]

    TASK [filebeat-role : Extract Filebeat in the installa
    ```

    </details>

    Тестирование с `tox` https://github.com/run0ut/logstash-role/releases/tag/1.3.0

    <details><summary>лог тестирования с tox</summary>

    ```log
    [root@fd421608b1bd logstash-role]# tox
    py36-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.4.0,arrow==1.2.2,bcrypt==3.2.0,binaryornot==0.4.4,bracex==2.2.1,cached-property==1.5.2,Cerberus==1.3.2,certifi==2021.10.8,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.0.4,click-help-colors==0.9.1,colorama==0.4.4,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==36.0.1,dataclasses==0.8,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,importlib-metadata==4.8.3,Jinja2==3.0.3,jinja2-time==0.2.0,MarkupSafe==2.0.1,molecule==3.6.1,molecule-docker==1.1.0,molecule-podman==1.1.0,packaging==21.3,paramiko==2.9.2,pathspec==0.9.0,pluggy==1.0.0,poyo==0.5.0,pycparser==2.21,Pygments==2.11.2,PyNaCl==1.5.0,pyparsing==3.0.7,python-dateutil==2.8.2,python-slugify==6.1.1,PyYAML==6.0,requests==2.27.1,rich==11.2.0,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,typing_extensions==4.1.1,urllib3==1.26.8,wcmatch==8.3,websocket-client==1.3.1,yamllint==1.26.3,zipp==3.6.0
    py36-ansible30 run-test-pre: PYTHONHASHSEED='1368912298'
    py36-ansible30 run-test: commands[0] | molecule test -s alternative --destroy=always
    INFO     alternative scenario test matrix: dependency, destroy, create, converge, verify, destroy
    INFO     Performing prerun...
    INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/702279/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
    INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/702279/collections:/root/.ansible/collections:/usr/share/ansible/collections
    INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/702279/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
    INFO     Using /root/.ansible/roles/stopfailing.logstash_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Running alternative > dependency
    Starting galaxy role install process
    - extracting elastic-role to /root/.cache/molecule/logstash-role/alternative/roles/elastic-role
    - elastic-role (main) was installed successfully
    - extracting kibana-role to /root/.cache/molecule/logstash-role/alternative/roles/kibana-role
    - kibana-role (main) was installed successfully
    - extracting filebeat-role to /root/.cache/molecule/logstash-role/alternative/roles/filebeat-role
    - filebeat-role (main) was installed successfully
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running alternative > destroy
    INFO     Sanity checks: 'podman'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True})

    TASK [Wait for instance(s) deletion to complete] *******************************
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '436843117277.50806', 'results_file': '/root/.ansible_async/436843117277.50806', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Running alternative > create

    PLAY [Create] ******************************************************************

    TASK [get podman executable path] **********************************************
    ok: [localhost]

    TASK [save path to executable as fact] *****************************************
    ok: [localhost]

    TASK [Log into a container registry] *******************************************
    skipping: [localhost] => (item="instance registry username: None specified")

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item=Dockerfile: None specified)

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item="Dockerfile: None specified; Image: docker.io/pycontribs/centos:7")

    TASK [Discover local Podman images] ********************************************
    ok: [localhost] => (item=instance)

    TASK [Build an Ansible compatible image] ***************************************
    skipping: [localhost] => (item=docker.io/pycontribs/centos:7)

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item="instance command: None specified")

    TASK [Remove possible pre-existing containers] *********************************
    changed: [localhost]

    TASK [Discover local podman networks] ******************************************
    skipping: [localhost] => (item=instance: None specified)

    TASK [Create podman network dedicated to this scenario] ************************
    skipping: [localhost]

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=instance)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item=instance)

    PLAY RECAP *********************************************************************
    localhost                  : ok=8    changed=3    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0

    INFO     Running alternative > converge

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [Include logstash-role] ***************************************************

    TASK [logstash-role : Download Logstash's rpm] *********************************
    skipping: [instance]

    TASK [logstash-role : Copy Logstash to manage host] ****************************
    skipping: [instance]

    TASK [logstash-role : Ensure Java is installed.] *******************************
    skipping: [instance]

    TASK [logstash-role : Install Logstash] ****************************************
    skipping: [instance]

    TASK [logstash-role : Configure startup options] *******************************
    skipping: [instance]

    TASK [logstash-role : Configure JVM options] ***********************************
    skipping: [instance]

    TASK [logstash-role : Create startup scripts] **********************************
    skipping: [instance]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    skipping: [instance] => (item=simple_config.conf)

    TASK [logstash-role : install iproute] *****************************************
    skipping: [instance]

    TASK [logstash-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [logstash-role : debug] ***************************************************
    skipping: [instance]

    TASK [logstash-role : Get Logstash tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [logstash-role : Copy Logstash to manage host] ****************************
    changed: [instance]

    TASK [logstash-role : Create directrory for Logstash] **************************
    changed: [instance]

    TASK [logstash-role : Extract Logstash in the installation directory] **********
    changed: [instance]

    TASK [logstash-role : Create java options directory] ***************************
    changed: [instance] => (item=/opt/logstash/7.14.0/config/jvm.options.d)

    TASK [logstash-role : Configure JVM options] ***********************************
    changed: [instance]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    changed: [instance] => (item=simple_config.conf)
    changed: [instance] => (item=pipelines.yml)
    changed: [instance] => (item=startup.options)

    TASK [logstash-role : Set environment Logstash] ********************************
    changed: [instance]

    TASK [logstash-role : try start Logstash binary in Docker] *********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/logstash.sh", "delta": "0:00:00.003583", "end": "2022-03-08 19:49:31.499768", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:49:31.496185", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [logstash-role : try start Logstash binary in Podman] *********************
    ok: [instance -> 127.0.0.1]

    PLAY RECAP *********************************************************************
    instance                   : ok=10   changed=7    unreachable=0    failed=0    skipped=11   rescued=1    ignored=0

    INFO     Running alternative > verify
    INFO     Running Ansible Verifier

    PLAY [Verify] ******************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [get elastic] *************************************************************

    TASK [elastic-role : Recollect facts] ******************************************
    ok: [instance]

    TASK [elastic-role : Download Elasticsearch's rpm] *****************************
    skipping: [instance]

    TASK [elastic-role : Install latest Elasticsearch] *****************************
    skipping: [instance]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    skipping: [instance]

    TASK [elastic-role : install iproute] ******************************************
    skipping: [instance]

    TASK [elastic-role : Recollect facts] ******************************************
    skipping: [instance]

    TASK [elastic-role : Get Elasticsearch tar.gz] *********************************
    ok: [instance -> localhost]

    TASK [elastic-role : Copy Elasticsearch to manage host] ************************
    changed: [instance]

    TASK [elastic-role : Create directrory for Elasticsearch] **********************
    changed: [instance]

    TASK [elastic-role : Extract Elasticsearch in the installation directory] ******
    changed: [instance]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    changed: [instance] => (item={'src': 'elasticsearch.yml.j2', 'dest': '/opt/elasticsearch/7.14.0/config/elasticsearch.yml'})
    changed: [instance] => (item={'src': 'jvm.options.j2', 'dest': '/opt/elasticsearch/7.14.0/config/jvm.options'})

    TASK [elastic-role : Set environment Elasticsearch] ****************************
    changed: [instance]

    TASK [elastic-role : Create group] *********************************************
    changed: [instance]

    TASK [elastic-role : Create user] **********************************************
    changed: [instance]

    TASK [elastic-role : Create directories] ***************************************
    changed: [instance] => (item=/var/log/elasticsearch)
    ok: [instance] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : Set permissions] ******************************************
    changed: [instance] => (item=/var/log/elasticsearch)
    changed: [instance] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : restart Elasticsearch binary on docker] *******************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -u elasticsearch -d -it instance bash /etc/profile.d/elasticsearch.sh", "delta": "0:00:00.003305", "end": "2022-03-08 19:51:25.606060", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:51:25.602755", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [elastic-role : restart Elasticsearch binary on podman] *******************
    ok: [instance -> 127.0.0.1]

    TASK [get kibana] **************************************************************

    TASK [kibana-role : Download Kibana's rpm] *************************************
    skipping: [instance]

    TASK [kibana-role : Install latest Kibana] *************************************
    skipping: [instance]

    TASK [kibana-role : Configure Kibana] ******************************************
    skipping: [instance]

    TASK [kibana-role : install iproute] *******************************************
    skipping: [instance]

    TASK [kibana-role : Recollect facts] *******************************************
    skipping: [instance]

    TASK [kibana-role : debug] *****************************************************
    skipping: [instance]

    TASK [kibana-role : Get Kibana tar.gz] *****************************************
    ok: [instance -> localhost]

    TASK [kibana-role : Copy Elasticsearch to manage host] *************************
    changed: [instance]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    changed: [instance]

    TASK [kibana-role : Extract Kibana in the installation directory] **************
    changed: [instance]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [instance]

    TASK [kibana-role : Set environment Kibana] ************************************
    changed: [instance]

    TASK [kibana-role : try start Kibana binary in Docker] *************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/kibana.sh", "delta": "0:00:00.003346", "end": "2022-03-08 19:53:14.631482", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:53:14.628136", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [kibana-role : try start Kibana binary in Podman] *************************
    ok: [instance -> 127.0.0.1]

    TASK [test elastic web] ********************************************************
    ok: [instance]

    TASK [test kibana web] *********************************************************
    FAILED - RETRYING: test kibana web (10 retries left).
    ok: [instance]

    TASK [apply filebeat-role to setup kibana dashboards] **************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [instance]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [instance]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    changed: [instance]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    changed: [instance]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [instance]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    changed: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    changed: [instance]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    changed: [instance]

    TASK [filebeat-role : restart Filebeat binary on Docker] ***********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/filebeat.sh", "delta": "0:00:00.003505", "end": "2022-03-08 19:55:04.994016", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:55:04.990511", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [filebeat-role : restart Filebeat binaryon Podman] ************************
    ok: [instance -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    ok: [instance]

    TASK [check filebeat is running on Docker] *************************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec instance pgrep filebeat", "delta": "0:00:00.003444", "end": "2022-03-08 19:56:40.984435", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:56:40.980991", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [check filebeat is running on Podman] *************************************
    ok: [instance -> 127.0.0.1]

    TASK [print what docker exec returned] *****************************************
    ok: [instance] => {
        "msg": "filebeat process id = 2350"
    }

    TASK [check filebeat index exists] *********************************************
    ok: [instance]

    TASK [checkif index not empty] *************************************************
    ok: [instance] => {
        "msg": "number of documents in filebeat index = 359"
    }

    TASK [apply filebeat-role to setup kibana dashboards] **************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [instance]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [instance]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    ok: [instance]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    ok: [instance]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [instance]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    ok: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    ok: [instance]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    ok: [instance]

    TASK [filebeat-role : restart Filebeat binary on Docker] ***********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/filebeat.sh", "delta": "0:00:00.003953", "end": "2022-03-08 19:57:20.335240", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:57:20.331287", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [filebeat-role : restart Filebeat binaryon Podman] ************************
    ok: [instance -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [make shure there are no any running logstashes on Docker] ****************
    ok: [instance -> 127.0.0.1]

    TASK [check logstash will answer normally on Docker] ***************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec instance /opt/logstash/7.14.0/bin/logstash -e 'input { stdin { } } output { stdout {} }'", "delta": "0:00:00.003487", "end": "2022-03-08 19:57:22.095761", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 19:57:22.092274", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [make shure there are no any running logstashes on Podman] ****************
    ok: [instance -> 127.0.0.1]

    TASK [check logstash will answer normally on Podman] ***************************
    ok: [instance -> 127.0.0.1]

    TASK [print logstash answer if previous command exited well (retcode = 0) on Podman] ***
    ok: [instance] => {
        "msg": [
            "Using bundled JDK: /opt/logstash/7.14.0/jdk",
            "Sending Logstash logs to /opt/logstash/7.14.0/logs which is now configured via log4j2.properties",
            "[2022-03-08T19:58:01,418][INFO ][logstash.runner          ] Log4j configuration path used is: /opt/logstash/7.14.0/config/log4j2.properties",
            "[2022-03-08T19:58:01,433][INFO ][logstash.runner          ] Starting Logstash {\"logstash.version\"=>\"7.14.0\", \"jruby.version\"=>\"jruby 9.2.19.0 (2.5.8) 2021-06-15 55810c552b OpenJDK 64-Bit Server VM 11.0.11+9 on 11.0.11+9 +indy +jit [linux-x86_64]\"}",
            "[2022-03-08T19:58:02,161][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified",
            "[2022-03-08T19:58:04,989][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}",
            "[2022-03-08T19:58:05,910][INFO ][org.reflections.Reflections] Reflections took 141 ms to scan 1 urls, producing 120 keys and 417 values ",
            "[2022-03-08T19:58:07,904][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>\"main\", \"pipeline.workers\"=>4, \"pipeline.batch.size\"=>125, \"pipeline.batch.delay\"=>50, \"pipeline.max_inflight\"=>500, \"pipeline.sources\"=>[\"config string\"], :thread=>\"#<Thread:0x18f9e311 run>\"}",
            "[2022-03-08T19:58:09,214][INFO ][logstash.javapipeline    ][main] Pipeline Java execution initialization time {\"seconds\"=>1.3}",
            "[2022-03-08T19:58:09,452][INFO ][logstash.javapipeline    ][main] Pipeline started {\"pipeline.id\"=>\"main\"}",
            "[2022-03-08T19:58:09,525][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}",
            "[2022-03-08T19:58:09,644][INFO ][logstash.javapipeline    ][main] Pipeline terminated {\"pipeline.id\"=>\"main\"}",
            "[2022-03-08T19:58:10,099][INFO ][logstash.pipelinesregistry] Removed pipeline from registry successfully {:pipeline_id=>:main}",
            "[2022-03-08T19:58:10,155][INFO ][logstash.runner          ] Logstash shut down."
        ]
    }

    PLAY RECAP *********************************************************************
    instance                   : ok=49   changed=19   unreachable=0    failed=0    skipped=26   rescued=6    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running alternative > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True})

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (299 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (298 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (297 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '896766878196.80413', 'results_file': '/root/.ansible_async/896766878196.80413', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    py39-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==2.0.0,ansible-lint==5.4.0,arrow==1.2.2,bcrypt==3.2.0,binaryornot==0.4.4,bracex==2.2.1,Cerberus==1.3.2,certifi==2021.10.8,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.0.4,click-help-colors==0.9.1,colorama==0.4.4,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==36.0.1,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,Jinja2==3.0.3,jinja2-time==0.2.0,MarkupSafe==2.1.0,molecule==3.6.1,molecule-docker==1.1.0,molecule-podman==1.1.0,packaging==21.3,paramiko==2.9.2,pathspec==0.9.0,pluggy==1.0.0,poyo==0.5.0,pycparser==2.21,Pygments==2.11.2,PyNaCl==1.5.0,pyparsing==3.0.7,python-dateutil==2.8.2,python-slugify==6.1.1,PyYAML==6.0,requests==2.27.1,rich==11.2.0,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,urllib3==1.26.8,wcmatch==8.3,websocket-client==1.3.1,yamllint==1.26.3
    py39-ansible30 run-test-pre: PYTHONHASHSEED='1368912298'
    py39-ansible30 run-test: commands[0] | molecule test -s alternative --destroy=always
    INFO     alternative scenario test matrix: dependency, destroy, create, converge, verify, destroy
    INFO     Performing prerun...
    INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/702279/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
    INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/702279/collections:/root/.ansible/collections:/usr/share/ansible/collections
    INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/702279/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
    INFO     Using /root/.ansible/roles/stopfailing.logstash_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Running alternative > dependency
    Starting galaxy role install process
    - extracting elastic-role to /root/.cache/molecule/logstash-role/alternative/roles/elastic-role
    - elastic-role (main) was installed successfully
    - extracting kibana-role to /root/.cache/molecule/logstash-role/alternative/roles/kibana-role
    - kibana-role (main) was installed successfully
    - extracting filebeat-role to /root/.cache/molecule/logstash-role/alternative/roles/filebeat-role
    - filebeat-role (main) was installed successfully
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running alternative > destroy
    INFO     Sanity checks: 'podman'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True})

    TASK [Wait for instance(s) deletion to complete] *******************************
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '702348875917.80788', 'results_file': '/root/.ansible_async/702348875917.80788', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Running alternative > create

    PLAY [Create] ******************************************************************

    TASK [get podman executable path] **********************************************
    ok: [localhost]

    TASK [save path to executable as fact] *****************************************
    ok: [localhost]

    TASK [Log into a container registry] *******************************************
    skipping: [localhost] => (item="instance registry username: None specified")

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item=Dockerfile: None specified)

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item="Dockerfile: None specified; Image: docker.io/pycontribs/centos:7")

    TASK [Discover local Podman images] ********************************************
    ok: [localhost] => (item=instance)

    TASK [Build an Ansible compatible image] ***************************************
    skipping: [localhost] => (item=docker.io/pycontribs/centos:7)

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item="instance command: None specified")

    TASK [Remove possible pre-existing containers] *********************************
    changed: [localhost]

    TASK [Discover local podman networks] ******************************************
    skipping: [localhost] => (item=instance: None specified)

    TASK [Create podman network dedicated to this scenario] ************************
    skipping: [localhost]

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=instance)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item=instance)

    PLAY RECAP *********************************************************************
    localhost                  : ok=8    changed=3    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0

    INFO     Running alternative > converge

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [Include logstash-role] ***************************************************

    TASK [logstash-role : Download Logstash's rpm] *********************************
    skipping: [instance]

    TASK [logstash-role : Copy Logstash to manage host] ****************************
    skipping: [instance]

    TASK [logstash-role : Ensure Java is installed.] *******************************
    skipping: [instance]

    TASK [logstash-role : Install Logstash] ****************************************
    skipping: [instance]

    TASK [logstash-role : Configure startup options] *******************************
    skipping: [instance]

    TASK [logstash-role : Configure JVM options] ***********************************
    skipping: [instance]

    TASK [logstash-role : Create startup scripts] **********************************
    skipping: [instance]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    skipping: [instance] => (item=simple_config.conf)

    TASK [logstash-role : install iproute] *****************************************
    skipping: [instance]

    TASK [logstash-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [logstash-role : debug] ***************************************************
    skipping: [instance]

    TASK [logstash-role : Get Logstash tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [logstash-role : Copy Logstash to manage host] ****************************
    changed: [instance]

    TASK [logstash-role : Create directrory for Logstash] **************************
    changed: [instance]

    TASK [logstash-role : Extract Logstash in the installation directory] **********
    changed: [instance]

    TASK [logstash-role : Create java options directory] ***************************
    changed: [instance] => (item=/opt/logstash/7.14.0/config/jvm.options.d)

    TASK [logstash-role : Configure JVM options] ***********************************
    changed: [instance]

    TASK [logstash-role : Create Logstash configuration files.] ********************
    changed: [instance] => (item=simple_config.conf)
    changed: [instance] => (item=pipelines.yml)
    changed: [instance] => (item=startup.options)

    TASK [logstash-role : Set environment Logstash] ********************************
    changed: [instance]

    TASK [logstash-role : try start Logstash binary in Docker] *********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/logstash.sh", "delta": "0:00:00.004441", "end": "2022-03-08 20:00:54.259699", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:00:54.255258", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [logstash-role : try start Logstash binary in Podman] *********************
    ok: [instance -> 127.0.0.1]

    PLAY RECAP *********************************************************************
    instance                   : ok=10   changed=7    unreachable=0    failed=0    skipped=11   rescued=1    ignored=0

    INFO     Running alternative > verify
    INFO     Running Ansible Verifier

    PLAY [Verify] ******************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [get elastic] *************************************************************

    TASK [elastic-role : Recollect facts] ******************************************
    ok: [instance]

    TASK [elastic-role : Download Elasticsearch's rpm] *****************************
    skipping: [instance]

    TASK [elastic-role : Install latest Elasticsearch] *****************************
    skipping: [instance]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    skipping: [instance]

    TASK [elastic-role : install iproute] ******************************************
    skipping: [instance]

    TASK [elastic-role : Recollect facts] ******************************************
    skipping: [instance]

    TASK [elastic-role : Get Elasticsearch tar.gz] *********************************
    ok: [instance -> localhost]

    TASK [elastic-role : Copy Elasticsearch to manage host] ************************
    changed: [instance]

    TASK [elastic-role : Create directrory for Elasticsearch] **********************
    changed: [instance]

    TASK [elastic-role : Extract Elasticsearch in the installation directory] ******
    changed: [instance]

    TASK [elastic-role : Configure Elasticsearch] **********************************
    changed: [instance] => (item={'src': 'elasticsearch.yml.j2', 'dest': '/opt/elasticsearch/7.14.0/config/elasticsearch.yml'})
    changed: [instance] => (item={'src': 'jvm.options.j2', 'dest': '/opt/elasticsearch/7.14.0/config/jvm.options'})

    TASK [elastic-role : Set environment Elasticsearch] ****************************
    changed: [instance]

    TASK [elastic-role : Create group] *********************************************
    changed: [instance]

    TASK [elastic-role : Create user] **********************************************
    changed: [instance]

    TASK [elastic-role : Create directories] ***************************************
    changed: [instance] => (item=/var/log/elasticsearch)
    ok: [instance] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : Set permissions] ******************************************
    changed: [instance] => (item=/var/log/elasticsearch)
    changed: [instance] => (item=/opt/elasticsearch/7.14.0)

    TASK [elastic-role : restart Elasticsearch binary on docker] *******************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -u elasticsearch -d -it instance bash /etc/profile.d/elasticsearch.sh", "delta": "0:00:00.005746", "end": "2022-03-08 20:02:45.965176", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:02:45.959430", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [elastic-role : restart Elasticsearch binary on podman] *******************
    ok: [instance -> 127.0.0.1]

    TASK [get kibana] **************************************************************

    TASK [kibana-role : Download Kibana's rpm] *************************************
    skipping: [instance]

    TASK [kibana-role : Install latest Kibana] *************************************
    skipping: [instance]

    TASK [kibana-role : Configure Kibana] ******************************************
    skipping: [instance]

    TASK [kibana-role : install iproute] *******************************************
    skipping: [instance]

    TASK [kibana-role : Recollect facts] *******************************************
    skipping: [instance]

    TASK [kibana-role : debug] *****************************************************
    skipping: [instance]

    TASK [kibana-role : Get Kibana tar.gz] *****************************************
    ok: [instance -> localhost]

    TASK [kibana-role : Copy Elasticsearch to manage host] *************************
    changed: [instance]

    TASK [kibana-role : Create directrory for Kibana] ******************************
    changed: [instance]

    TASK [kibana-role : Extract Kibana in the installation directory] **************
    changed: [instance]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [instance]

    TASK [kibana-role : Set environment Kibana] ************************************
    changed: [instance]

    TASK [kibana-role : try start Kibana binary in Docker] *************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/kibana.sh", "delta": "0:00:00.009146", "end": "2022-03-08 20:04:33.836125", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:04:33.826979", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [kibana-role : try start Kibana binary in Podman] *************************
    ok: [instance -> 127.0.0.1]

    TASK [test elastic web] ********************************************************
    ok: [instance]

    TASK [test kibana web] *********************************************************
    FAILED - RETRYING: test kibana web (10 retries left).
    ok: [instance]

    TASK [apply filebeat-role to setup kibana dashboards] **************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [instance]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [instance]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    changed: [instance]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    changed: [instance]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [instance]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    changed: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    changed: [instance]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    changed: [instance]

    TASK [filebeat-role : restart Filebeat binary on Docker] ***********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/filebeat.sh", "delta": "0:00:00.005031", "end": "2022-03-08 20:06:37.565311", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:06:37.560280", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [filebeat-role : restart Filebeat binaryon Podman] ************************
    ok: [instance -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    ok: [instance]

    TASK [check filebeat is running on Docker] *************************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec instance pgrep filebeat", "delta": "0:00:00.005188", "end": "2022-03-08 20:08:12.550178", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:08:12.544990", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [check filebeat is running on Podman] *************************************
    ok: [instance -> 127.0.0.1]

    TASK [print what docker exec returned] *****************************************
    ok: [instance] => {
        "msg": "filebeat process id = 2413"
    }

    TASK [check filebeat index exists] *********************************************
    ok: [instance]

    TASK [checkif index not empty] *************************************************
    ok: [instance] => {
        "msg": "number of documents in filebeat index = 361"
    }

    TASK [apply filebeat-role to setup kibana dashboards] **************************

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    skipping: [instance]

    TASK [filebeat-role : Install latest Filebeat] *********************************
    skipping: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    skipping: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    skipping: [instance]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [filebeat-role : install iproute] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Recollect facts] *****************************************
    skipping: [instance]

    TASK [filebeat-role : Get Filebeat tar.gz] *************************************
    ok: [instance -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    ok: [instance]

    TASK [filebeat-role : Create directrory for Filebeat] **************************
    ok: [instance]

    TASK [filebeat-role : Extract Filebeat in the installation directory] **********
    ok: [instance]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [instance]

    TASK [filebeat-role : Set environment Filebeat] ********************************
    ok: [instance]

    TASK [filebeat-role : Enable and configure the system module] ******************
    ok: [instance]

    TASK [filebeat-role : Enable and configure the elasticsearch module] ***********
    ok: [instance]

    TASK [filebeat-role : restart Filebeat binary on Docker] ***********************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec -d -it instance bash /etc/profile.d/filebeat.sh", "delta": "0:00:00.004592", "end": "2022-03-08 20:08:52.934926", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:08:52.930334", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [filebeat-role : restart Filebeat binaryon Podman] ************************
    ok: [instance -> 127.0.0.1]

    TASK [filebeat-role : Load Kibana dashboards] **********************************
    skipping: [instance]

    TASK [make shure there are no any running logstashes on Docker] ****************
    ok: [instance -> 127.0.0.1]

    TASK [check logstash will answer normally on Docker] ***************************
    fatal: [instance -> 127.0.0.1]: FAILED! => {"changed": false, "cmd": "docker exec instance /opt/logstash/7.14.0/bin/logstash -e 'input { stdin { } } output { stdout {} }'", "delta": "0:00:00.005520", "end": "2022-03-08 20:08:54.416189", "msg": "non-zero return code", "rc": 127, "start": "2022-03-08 20:08:54.410669", "stderr": "/bin/sh: docker: command not found", "stderr_lines": ["/bin/sh: docker: command not found"], "stdout": "", "stdout_lines": []}

    TASK [make shure there are no any running logstashes on Podman] ****************
    ok: [instance -> 127.0.0.1]

    TASK [check logstash will answer normally on Podman] ***************************
    ok: [instance -> 127.0.0.1]

    TASK [print logstash answer if previous command exited well (retcode = 0) on Podman] ***
    ok: [instance] => {
        "msg": [
            "Using bundled JDK: /opt/logstash/7.14.0/jdk",
            "Sending Logstash logs to /opt/logstash/7.14.0/logs which is now configured via log4j2.properties",
            "[2022-03-08T20:09:37,220][INFO ][logstash.runner          ] Log4j configuration path used is: /opt/logstash/7.14.0/config/log4j2.properties",
            "[2022-03-08T20:09:37,233][INFO ][logstash.runner          ] Starting Logstash {\"logstash.version\"=>\"7.14.0\", \"jruby.version\"=>\"jruby 9.2.19.0 (2.5.8) 2021-06-15 55810c552b OpenJDK 64-Bit Server VM 11.0.11+9 on 11.0.11+9 +indy +jit [linux-x86_64]\"}",
            "[2022-03-08T20:09:37,992][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified",
            "[2022-03-08T20:09:40,561][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}",
            "[2022-03-08T20:09:41,128][INFO ][org.reflections.Reflections] Reflections took 130 ms to scan 1 urls, producing 120 keys and 417 values ",
            "[2022-03-08T20:09:42,891][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>\"main\", \"pipeline.workers\"=>4, \"pipeline.batch.size\"=>125, \"pipeline.batch.delay\"=>50, \"pipeline.max_inflight\"=>500, \"pipeline.sources\"=>[\"config string\"], :thread=>\"#<Thread:0x14106fff run>\"}",
            "[2022-03-08T20:09:44,261][INFO ][logstash.javapipeline    ][main] Pipeline Java execution initialization time {\"seconds\"=>1.36}",
            "[2022-03-08T20:09:44,433][INFO ][logstash.javapipeline    ][main] Pipeline started {\"pipeline.id\"=>\"main\"}",
            "[2022-03-08T20:09:44,513][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}",
            "[2022-03-08T20:09:44,634][INFO ][logstash.javapipeline    ][main] Pipeline terminated {\"pipeline.id\"=>\"main\"}",
            "[2022-03-08T20:09:45,103][INFO ][logstash.pipelinesregistry] Removed pipeline from registry successfully {:pipeline_id=>:main}",
            "[2022-03-08T20:09:45,166][INFO ][logstash.runner          ] Logstash shut down."
        ]
    }

    PLAY RECAP *********************************************************************
    instance                   : ok=49   changed=19   unreachable=0    failed=0    skipped=26   rescued=6    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running alternative > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True})

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (299 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (298 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (297 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (296 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (295 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (294 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (293 retries left).
    FAILED - RETRYING: Wait for instance(s) deletion to complete (292 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '870878609950.9347', 'results_file': '/root/.ansible_async/870878609950.9347', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    ____________________________________________________________________________________________________ summary _____________________________________________________________________________________________________
    py36-ansible30: commands succeeded
    py39-ansible30: commands succeeded
    congratulations :)
    ```

    </details>

2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.

    Стек обновится при изменении версии в конфигах.

3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечате адекватно.

    https://github.com/run0ut/logstash-role/blob/82e6cd57b8a88fdf037a88841d72fadd5be573a9/molecule/alternative/verify.yml#L91-L128

4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.

    https://github.com/run0ut/logstash-role/blob/main/molecule/alternative/verify.yml

5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.

    https://github.com/run0ut/logstash-role/blob/main/molecule/alternative/verify.yml

6. Выложите свои roles в репозитории. В ответ приведите ссылки.

    - Основные роли 
        - https://github.com/run0ut/kibana-role
        - https://github.com/run0ut/filebeat-role
    - Дополнительное задание 
        - https://github.com/run0ut/logstash-role
    - В тестах с интеграцией используется моя роль Elasticsearch. Мне не подошла роль Алескея и я создал свою на её основе:
        - https://github.com/run0ut/elastic-role