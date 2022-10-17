################################################################################
# Деплой приложения

# 
resource "null_resource" "app" {
  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} apply -f ../02-app/manifests/
    EOF
  }


  depends_on = [
    null_resource.kube_prometheus
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}

################################################################################
# Deploy Atlantis

# -------------------------------------------------
# Statefulset со внешним IP web-интерфейса Atlantis
# чтобы на Github работал переход в "Details"
data "template_file" "atlantis_statefulset" {
  template = file("${path.module}/templates/atlantis_statefulset.tpl")

  vars = {
    atlantis_ip = "${yandex_compute_instance.control.0.network_interface.0.nat_ip_address}"
  }

  depends_on = [
    null_resource.app
  ]
}

# -------------------------------------------------
# Сохранение рендера манифеста в файл
resource "null_resource" "atlantis_manifest" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    # command = "echo '${data.template_file.atlantis_statefulset.rendered}' > ../04-atlantis/manifests/10-satatefulSet.yml"
    command = "${format("cat <<\"EOF\" > \"%s\"\n%s\nEOF", "../04-atlantis/manifests/10-satatefulSet.yml", data.template_file.atlantis_statefulset.rendered)}"
  }

  triggers = {
    template = data.template_file.kubectl.rendered
  }
}

# -------------------------------------------------
# Создание configmap для монтирования в Атлантис
# - ssh закрытый и открый ключи для создания инстансов и доступа на сервера
# - .terraformrc нужен для РФ, т.к. Терраформ реджистри блокирует обращения из России
# - .auto.tfvars с некоторыми параметрами провайдера Яндекс, чтобы не мержить в репозиторий
# - key.json - ключ сервис-аккаунта Яндекса с правами на работу в облаке, тоже чтобы не мержить
# - server.yaml - конфигурация сервера, чтобы работал atlantis.yaml из репозитория 
resource "null_resource" "atlantis_configmaps" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} \
      create configmap atlantis-files \
        --from-file=ssh=$HOME/.ssh/id_rsa \
        --from-file=ssh-pub=$HOME/.ssh/id_rsa.pub \
        --from-file=terraformrc=$HOME/.terraformrc \
        --from-file=auto-tfvars=.auto.tfvars \
        --from-file=key-json=key.json \
        --from-file=server-config=server.yaml
    EOF
  }

  depends_on = [
    null_resource.app
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}

# -------------------------------------------------
# Деплой Atlantis в кластер
# Первая команда добавляет configmap с токенами GitHub 
# Вторая деплоит Атлантис
resource "null_resource" "atlantis" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} create secret generic atlantis-vcs --from-file=../04-atlantis/token --from-file=../04-atlantis/webhook-secret
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} apply -f ../04-atlantis/manifests/
    EOF
  }


  depends_on = [
    null_resource.atlantis_manifest
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}

################################################################################
# Деплой Jenkins

# -------------------------------------------------
# Конфигурации для провижена Jenkins
resource "null_resource" "jenkins_configmaps" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} \
      create configmap jenkins-files \
        --from-file=credentials=../05-jenkins/exported-credentials.xml \
        --from-file=diploma-test-app-stage=../05-jenkins/jobs/diploma-test-app-stage/config.xml \
        --from-file=diploma-test-app-prod=../05-jenkins/jobs/diploma-test-app-prod/config.xml \
        --from-file=kubeconfig=kubeconfig/config-prod
    EOF
  }

  depends_on = [
    null_resource.app
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}

# -------------------------------------------------
# Деплой Jenkins в кластер
resource "null_resource" "jenkins" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} apply -f ../05-jenkins/manifests/
    EOF
  }


  depends_on = [
    null_resource.jenkins_configmaps
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}