################################################################################
# Image

data "yandex_compute_image" "ubuntu" {
  family = "lamp"
  # image_id = "fd81u0g6sfk13ivcfcrm" # lamp-v20220711
}

# ################################################################################
# # Группа для Network Load Balancer


# resource "yandex_compute_instance" "public_instance" {
#   name      = "n151-public"
#   hostname    = "n151-public.local"

#   platform_id = "standard-v1"

#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 100
#   }

#   boot_disk {
#     initialize_params {
#       image_id = data.yandex_compute_image.ubuntu.id
#       type     = "network-hdd"
#       size     = "50"
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.public.id
#     nat       = true
#     ipv6      = false
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("./id_rsa_n15.pub")}"
#   }
# }

# resource "yandex_compute_instance" "private_instance" {
#   name      = "n151-private"
#   hostname    = "n151-private.local"

#   platform_id = "standard-v1"

#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 100
#   }

#   boot_disk {
#     initialize_params {
#       image_id = data.yandex_compute_image.ubuntu.id
#       type     = "network-hdd"
#       size     = "50"
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.private.id
#     nat       = false
#     ipv6      = false
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("./id_rsa_n15.pub")}"
#   }
# }
