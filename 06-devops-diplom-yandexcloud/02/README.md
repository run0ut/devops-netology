# Предварительные настройки 

Необходимый софт:
- terraform
- ansible
- pip3
- git
- kubectl

Необходимые реквизиты:
- Аккаунт GitHub и Personal Access Token
- Аккаунт Docker Hub
- Аккаунт Yandex Cloud и Service Account, ключ авторизации сервисного аккаунта
- Закрытый и открытый ключ .ssh в `~/.ssh`

Что нужно настроить:
- Настройте git на локальной машине для работы с репозиториями в GitHub, должна быть возможность делать push по ключу ssh, без ввода пароля
- Создайте два репозитория: `diploma-terraform` и `diploma-test-app`

# Как запустить

1. Если Вы из РФ, скопируйте конфиг Terraform [01-yandex/.terraformrc](01-yandex/.terraformrc) в домашнюю директорию, чтобы он обращался к репозиторию Яндекса
    ```bash
    cp 01-yandex/.terraformrc ~/
    ```
1. Зайдите в папку [00-bucket](00-bucket)
    - Заполните переменные [00-bucket/.auto.tfvars](00-bucket/.auto.tfvars)
    - Примените конфигурацию
        ```bash
        terraform init
        terraform apply -auto-approve
        ```
1. Зайдите в папку [01-yandex](01-yandex)
    - Отправьте файлы конфигурации Terraform в репозиторий, например:
        ```bash
        repo='diploma-terraform`
        git init 
        git add *tf {ansible,kubeconfig}/README.md templates/* README.md *yaml--force 
        git add .gitignore && git add .terraformrc
        git commit -m'Первый коммит'
        git branch -M main 
        git remote add origin git@github.com:run0ut/$repo.git 
        git push --set-upstream origin main
        ```
    - Создайте воркспейсы Тераформ `stage` и `prod` и примените конфигурацию:
        ```bash
        terraform init
        terraform workspace new stage
        terraform workspace new prod
        terraform workspace select stage 
        terraform apply -auto-approve
        terraform workspace select prod 
        terraform apply -auto-approve
        ```
1. После применения конфигурации prod, Terraform выведет ссылки на все ресурсы, которые должны быть доступны извне: приложение, Grafana, Atlantis, Jenkins.

    Приложение пока будет недоступно.

1. Зайдите в папку [02-app](02-app):
    - Отправьте все файлы в репозиторий с кодом приложения
    - В той же папке несколько раз выполните скрипт, чтобы создать теги и отправить их в репозиторий:
        ```bash
        {
            tag_n=0
            date +%s > dummy
            git add dummy 
            tag_n=$((tag_n+1))
            git commit -m "tag $tag_n"
            git tag v0.0.$tag_n
            git push --tags origin main
        }
        ```

## Возможно потребуется создать докер-контейнер Jenkins с плагинами

Для задания был подготовлен докер-контейнер с Jenkins с нужными плагинами. Если со временем я его удалю, то вначале нужно будет сделать собственный. Это нужно делать вначале, иначе не получится автоматический развренуть Jenkins.

1. Зайдите в папку [05-jenkins](05-jenkins), запустите jenkins с docker-compose, 
1. Пройдите шаги мастера, подождите когда установятся планигы
1. Добавьте плагин [Basic Branch Build Strategies Plugin](https://github.com/jenkinsci/basic-branch-build-strategies-plugin)
1. Содержимое папки `data/plugins` положите в [05-jenkins/plugins](05-jenkins/plugins)
1. Создайте docker контейнер, отправьте в DockerHub
1. Поправьте image в [manifests/00-deployment.yml](manifests/00-deployment.yml) на созданный Вами