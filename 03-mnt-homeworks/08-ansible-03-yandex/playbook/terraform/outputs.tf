output "elk_ip" {
  value       = yandex_compute_instance.elk.network_interface.0.nat_ip_address
  description = "Приватный IP на Яндексе, elk"
}
output "fbeat_ip" {
  value       = yandex_compute_instance.fbeat.network_interface.0.nat_ip_address
  description = "Приватный IP на Яндексе, filebeat"
}
