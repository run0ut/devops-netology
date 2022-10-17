
################################################################################
# Деплой Jenkins

# -------------------------------------------------
# Файл для импорта логина и пароля к аккаунту Докера
# в Jenkins Credentials
data "template_file" "jenkins_credentials" {
  template = file("${path.module}/templates/exported-credentials.tpl")

  vars = {
    login    = "${var.dockerhub_login}"
    password = "${var.dockerhub_password}"
  }

  depends_on = [
    null_resource.app
  ]
}

# -------------------------------------------------
# Сохранение рендера креденшелов в файл
resource "null_resource" "jenkins_credentials" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = format("cat <<\"EOF\" > \"%s\"\n%s\nEOF", "../05-atlantis/exported-credentials.xml", data.template_file.jenkins_credentials.rendered)
  }

  triggers = {
    template = data.template_file.jenkins_credentials.rendered
  }
}

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
    null_resource.jenkins_credentials
  ]

  triggers = {
    cluster_instance_ids = join(",", [join(",", yandex_compute_instance.control.*.id), join(",", yandex_compute_instance.worker.*.id)])
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
    cluster_instance_ids = join(",", [join(",", yandex_compute_instance.control.*.id), join(",", yandex_compute_instance.worker.*.id)])
  }
}