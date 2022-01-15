# AWS регион, который используется в данный момент,
output "Yandex_zone" {
  value = yandex_compute_instance.vm.zone
}

# Приватный IP ec2 инстансы,
output "IP_compute_instance" {
  value = yandex_compute_instance.vm.network_interface.0.ip_address
}

# Идентификатор подсети в которой создан инстанс.
output "Yandex_vpc_subnet" {
  value = resource.yandex_vpc_subnet.subnet.id
}