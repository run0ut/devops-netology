output "public_ip" {
  value = toset([
    for instance in yandex_compute_instance.vm : instance.network_interface.0.nat_ip_address
  ])
  description = "Публичный IP инстансов в Y.Cloud"
}
