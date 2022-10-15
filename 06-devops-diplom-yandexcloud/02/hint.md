# Yandex Object Storage + Terraform state

https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage#configure-terraform

https://www.terraform.io/language/settings/backends/s3

# Workspaces

https://www.terraform.io/language/state/workspaces - офф. дока

https://adamtheautomator.com/terraform-workspace/ - пример как создавать ресурсы для разных воркспейсов один манифестом, используя переменную `${terraform.workspace}`

https://www.padok.fr/en/blog/terraform-workspaces

# Atlantis

https://hub.docker.com/r/runatlantis/atlantis образ

https://github.com/runatlantis/atlantis GitHub

https://www.runatlantis.io/docs/deployment.html#kubernetes-manifests деплой в Кубер из манифестов

https://www.runatlantis.io/docs/configuring-webhooks.html#github-github-enterprise настройка хуков


[раз](https://stackoverflow.com/questions/43544370/kubernetes-how-to-set-volumemount-user-group-and-file-permissions)
[два](https://discuss.kubernetes.io/t/write-permissions-on-volume-mount-with-security-context-fsgroup-option/16524)
Решение ошибки `mkdir /atlantis/bin: Permission denied` - создать init контейнер, который смонтирует тот же раздел и поправит права на папку

Пример настроек Atlantis из 2-го модуля: 
- [atlantis.yaml](https://github.com/run0ut/devops-netology/blob/main/02-virt-homeworks/misc/74/atlantis.yaml)
- [server.yaml](https://github.com/run0ut/devops-netology/blob/main/02-virt-homeworks/misc/74/server/server.yaml)

# Jenkins

---

Пригодилось:

[Установка в Кубер](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-yaml-files)

[Dockerfile для Jenkins в докере](https://github.com/jenkinsci/docker-workflow-plugin/blob/docker-workflow-1.12/demo/Dockerfile) - тут подсмотрел установку Докера в контейнер с Дженскинсом и добавление плагинов

[Билд образов, пуш в докер и использование креденшелз для docker login](https://www.liatrio.com/blog/building-with-docker-using-jenkins-pipelines)


[Youtube, решение подобной задачи со сборкой по коммиту](https://www.youtube.com/watch?v=0D_wKERZ2zo)

[Jenkinsfile из видео](https://github.com/ksemaev/project_template/tree/master/jenkinsfiles)

[Как сохоранить вывод sh в переменную](https://stackoverflow.com/questions/36547680/how-do-i-get-the-output-of-a-shell-command-executed-using-into-a-variable-from-j)

[Примеры пайплайнов](https://www.jenkins.io/doc/book/pipeline/syntax/#declarative-steps)

---

Не пригодилось пока:

[Установка с оператором](https://jenkinsci.github.io/kubernetes-operator/docs/getting-started/latest/installing-the-operator/) (не исопльзовал)

[Docker pipeline](https://docs.cloudbees.com/docs/admin-resources/latest/plugins/docker-workflow) - не пригодилось, нет особой разницы между этим и `sh`, `docker cli` всё равно должна быть установлена

[Примеры билда контейнеров с Docker pipeline](https://www.jenkins.io/doc/book/pipeline/docker/#building-containers)