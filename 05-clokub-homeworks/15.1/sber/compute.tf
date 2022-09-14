################################################################################
# image для виртуалок

data "sbercloud_images_image" "ubuntu" {
  name        = "Ubuntu 20.04 server 64bit"
  visibility  = "public"
  most_recent = true
}

################################################################################
# Ключ для доступа по ssh из первой части ДЗ с Яндексом
resource "sbercloud_compute_keypair" "id_rsa_n15" {
  name       = "id_rsa_n15"
  public_key = file("../yandex/id_rsa_n15.pub")
}

################################################################################
# Инстанс public и привязка внешнего IP

resource "sbercloud_compute_instance" "public" {
  name              = "public"
  image_id          = data.sbercloud_images_image.ubuntu.id
  flavor_id         = "s6.small.1"
  key_pair          = sbercloud_compute_keypair.id_rsa_n15.id
  security_groups   = [sbercloud_networking_secgroup.n15.name]
  availability_zone = sbercloud_vpc_subnet.public.availability_zone
  system_disk_type  = "SSD"
  system_disk_size  = 10

  delete_disks_on_termination = true

  network {
    uuid = sbercloud_vpc_subnet.public.id
  }
}

resource "sbercloud_compute_eip_associate" "associated" {
  public_ip   = sbercloud_vpc_eip.eip_1.address
  instance_id = sbercloud_compute_instance.public.id
}

################################################################################
# Инстанс private

resource "sbercloud_compute_instance" "private" {
  name              = "private"
  image_id          = data.sbercloud_images_image.ubuntu.id
  flavor_id         = "s6.small.1"
  key_pair          = sbercloud_compute_keypair.id_rsa_n15.id
  security_groups   = [sbercloud_networking_secgroup.n15.name]
  availability_zone = sbercloud_vpc_subnet.private.availability_zone
  system_disk_type  = "SSD"
  system_disk_size  = 10

  delete_disks_on_termination = true

  network {
    uuid = sbercloud_vpc_subnet.private.id
  }
}