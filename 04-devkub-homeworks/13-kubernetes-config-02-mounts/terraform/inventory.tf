data "template_file" "inventory" {
  template = file("${path.module}/templates/inventory.tpl")

  vars = {
    connection_strings_master = join("\n", formatlist("%s ansible_host=%s ansible_user=ubuntu", yandex_compute_instance.control.*.name, yandex_compute_instance.control.*.network_interface.0.nat_ip_address))
    connection_strings_node   = join("\n", formatlist("%s ansible_host=%s ansible_user=ubuntu", yandex_compute_instance.worker.*.name, yandex_compute_instance.worker.*.network_interface.0.nat_ip_address))
    nfs_node                  = join("\n", formatlist("%s ansible_host=%s ansible_user=ubuntu", yandex_compute_instance.nfs.*.name, yandex_compute_instance.nfs.*.network_interface.0.nat_ip_address))
    list_master               = join("\n",yandex_compute_instance.control.*.name)
    list_node                 = join("\n", yandex_compute_instance.worker.*.name)
  }

  depends_on = [
    null_resource.folder
  ]
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ./kubespray/inventory/mycluster/inventory.ini"
  }

  triggers = {
    template = data.template_file.inventory.rendered
  }
}