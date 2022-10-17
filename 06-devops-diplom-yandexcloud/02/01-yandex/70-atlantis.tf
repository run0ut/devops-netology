################################################################################
# Деплой Atlantis

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
        --from-file=terraformrc=.terraformrc \
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
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} create secret generic atlantis-vcs --from-literal=token=${var.github_personal_access_token} --from-literal=webhook-secret=${var.github_webhook_secret}
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

# -------------------------------------------------
# Настройка веб-хука репозитория для обращения к Atlantis

locals {
  atlantis_ip = yandex_compute_instance.control.0.network_interface.0.nat_ip_address
}

resource "null_resource" "atlantis_webhook" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      # Получить Personal Access Token для доступа к настройкам репозитория
      id=''
      hook=''
      token=$(cat ../04-atlantis/token)
      # Получить данные о хуках репозитория
      id=$(curl -sS \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $token" \
        https://api.github.com/repos/run0ut/diploma-terraform/hooks | jq .[0].id)
      if [[ "$id" == "null" ]]; then
        # Если хука нет, создать
        echo "Create hook"
        curl -sS \
          -X POST \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $token" \
          https://api.github.com/repos/run0ut/diploma-terraform/hooks \
          -d '{"name":"web","active":true,"events":["push","pull_request","pull_request_review","issue_comment"],"config":{"url":"http://${local.atlantis_ip}:30141/events","content_type":"json","insecure_ssl":"0","secret":"diplomasecret"}}'
      else
        # Если хук есть, обновить URL
        echo "Update hook"
        curl -sS \
          -X PATCH \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $token" \
          https://api.github.com/repos/run0ut/diploma-terraform/hooks/$id \
          -d '{"name":"web","active":true,"events":["push","pull_request","pull_request_review","issue_comment"],"config":{"url":"http://${local.atlantis_ip}:30141/events","content_type":"json","insecure_ssl":"0","secret":"diplomasecret"}}'
      fi
    EOF
    interpreter = [
      "/bin/bash",
      "-c"
    ]
  }

  depends_on = [
    null_resource.atlantis
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}
