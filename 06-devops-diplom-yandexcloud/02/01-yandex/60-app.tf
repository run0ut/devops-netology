################################################################################
# Деплой приложения

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
