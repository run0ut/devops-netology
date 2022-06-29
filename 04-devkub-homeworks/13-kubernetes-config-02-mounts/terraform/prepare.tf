resource "null_resource" "clean_folder" {
  provisioner "local-exec" {
    command = "rm -rf kubespray"
  }

  depends_on = [
    yandex_compute_instance.control,
    yandex_compute_instance.worker
  ]
}

resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = "git clone https://github.com/kubernetes-sigs/kubespray.git"
  }

  depends_on = [
    null_resource.clean_folder
  ]
}

resource "null_resource" "requirements" {
  provisioner "local-exec" {
    command = "pip3 install -r kubespray/requirements.txt"
  }

  depends_on = [
    null_resource.git_clone
  ]
}

resource "null_resource" "folder" {
  provisioner "local-exec" {
    command = "cp -rfp kubespray/inventory/sample kubespray/inventory/mycluster"
  }

  depends_on = [
    null_resource.requirements
  ]
}