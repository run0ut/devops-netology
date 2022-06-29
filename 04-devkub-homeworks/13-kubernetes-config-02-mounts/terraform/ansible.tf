resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 50"
  }

  depends_on = [
    null_resource.inventories
  ]
}

resource "null_resource" "public_access" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -e 'hw_index=${var.hw_index}' -i kubespray/inventory/mycluster/inventory.ini ansible/kubespray_ssl.yml -b -v"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i kubespray/inventory/mycluster/inventory.ini kubespray/cluster.yml -b -v"
  }

  depends_on = [
    null_resource.public_access
  ]
}

resource "null_resource" "kubectl_host" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -e 'hw_index=${var.hw_index}' -i kubespray/inventory/mycluster/inventory.ini ansible/kubectl.yml -b -v"
  }

  depends_on = [
    null_resource.cluster
  ]
}

resource "null_resource" "nfs" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -e 'hw_index=${var.hw_index}' -i kubespray/inventory/mycluster/inventory.ini ansible/nfs.yml -b -v"
  }

  depends_on = [
    null_resource.kubectl_host
  ]
}