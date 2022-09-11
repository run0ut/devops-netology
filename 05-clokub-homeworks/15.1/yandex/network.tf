resource "yandex_vpc_network" "network" {
  name = "network-netology-15-1"
}

resource "yandex_vpc_subnet" "public" {
  name = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  # zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_route_table" "private_to_public" {
  name = "private to public"
  network_id = yandex_vpc_network.network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    # next_hop_address = yandex_compute_instance.public_instance.network_interface.0.ip_address
    next_hop_address = yandex_compute_instance.public_instance.network_interface.0.ip_address
  }
}

resource "yandex_vpc_subnet" "private" {
  name = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  # zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.private_to_public.id
}
