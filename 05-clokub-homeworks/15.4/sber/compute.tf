################################################################################
# Ключ для доступа по ssh из первой части ДЗ с Яндексом 15.1
resource "sbercloud_compute_keypair" "id_rsa_n15" {
  name       = "id_rsa_n15"
  public_key = file("../../15.1/yandex/id_rsa_n15.pub")
}

################################################################################
# image для виртуалок

data "sbercloud_images_image" "centos" {
  name        = "CentOS 7.6 64bit"
  visibility  = "public"
  most_recent = true
}

# ################################################################################
# # Инстанс public

# resource "sbercloud_compute_instance" "private" {
#   name              = "private"
#   image_id          = data.sbercloud_images_image.centos.id
#   flavor_id         = "s6.small.1"
#   key_pair          = sbercloud_compute_keypair.id_rsa_n15.id
#   security_groups   = [sbercloud_networking_secgroup.n15.name]
#   availability_zone = sbercloud_vpc_subnet.private.availability_zone
#   system_disk_type  = "SSD"
#   system_disk_size  = 10

#   delete_disks_on_termination = true
#   network {
#     uuid = sbercloud_vpc_subnet.private.id
#   }
# }
