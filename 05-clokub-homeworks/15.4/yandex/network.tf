resource "yandex_vpc_network" "network" {
  name = "network-netology-15"
}

resource "yandex_vpc_subnet" "publicA" {
  name = "public-a"
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "publicB" {
  name = "public-b"
  v4_cidr_blocks = ["192.168.40.0/24"]
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "publicC" {
  name = "public-c"
  v4_cidr_blocks = ["192.168.50.0/24"]
  zone = "ru-central1-c"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "zoneA" {
  name = "private-A"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "zoneB" {
  name = "private-B"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "zoneC" {
  name = "private-C"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone = "ru-central1-c"
  network_id = yandex_vpc_network.network.id
}
