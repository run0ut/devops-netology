################################################################################
# Deploy App

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

resource "null_resource" "atlantis" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} apply -f ../04-atlantis/manifests/
    EOF
  }


  depends_on = [
    null_resource.app
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}

################################################################################
# Deploy Jenkins

resource "null_resource" "jenkins_configmaps" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} \
      create configmap jenkins-files \
        --from-file=credentials=../05-jenkins/credentials.xml \
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

resource "null_resource" "jenkins" {
  count = (terraform.workspace == "prod") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
      kubectl --kubeconfig=./kubeconfig/config-${terraform.workspace} apply -f ../05-jenkins/manifests/
    EOF
  }


  depends_on = [
    # null_resource.docker_for_jenkins
    # null_resource.app
    null_resource.jenkins_configmaps
  ]

  triggers = {
    cluster_instance_ids = join(",",[join(",",yandex_compute_instance.control.*.id), join(",",yandex_compute_instance.worker.*.id)])
  }
}