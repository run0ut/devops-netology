################################################################################
# VPC и сабнеты

resource "yandex_vpc_network" "network" {
  name = "network-netology-15"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.network.id
}
