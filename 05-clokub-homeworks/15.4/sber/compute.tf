# ################################################################################
# # image для виртуалок

# data "sbercloud_images_image" "centos" {
#   name        = "CentOS 7.6 64bit"
#   visibility  = "public"
#   most_recent = true
# }

# ################################################################################
# # Ключ для доступа по ssh из первой части ДЗ с Яндексом 15.1
# resource "sbercloud_compute_keypair" "id_rsa_n15" {
#   name       = "id_rsa_n15"
#   public_key = file("../../15.1/yandex/id_rsa_n15.pub")
# }

# ################################################################################
# # Инстанс public и привязка внешнего IP

# resource "sbercloud_compute_instance" "public" {
#   name              = "public"
#   image_id          = data.sbercloud_images_image.centos.id
#   flavor_id         = "s6.small.1"
#   key_pair          = sbercloud_compute_keypair.id_rsa_n15.id
#   security_groups   = [sbercloud_networking_secgroup.n15.name]
#   availability_zone = sbercloud_vpc_subnet.public.availability_zone
#   system_disk_type  = "SSD"
#   system_disk_size  = 10

#   delete_disks_on_termination = true

#   user_data = <<EOF
# #!/bin/bash
# wget https://obs-community-intl.obs.ap-southeast-1.myhuaweicloud.com/obsutil/current/obsutil_linux_amd64.tar.gz
# tar xzf obsutil_linux_amd64.tar.gz
# cd obsutil_linux_amd64_5.3.4/
# ./obsutil config -i=${var.sber_access_key} -k=${var.sber_secret_key} -e=obs.${var.sber_region}.hc.sbercloud.ru
# ./obsutil cp obs://${sbercloud_obs_bucket.n15-encrypted.bucket}/${sbercloud_obs_bucket_object.netology-logo.key} obs://${sbercloud_obs_bucket.n15.bucket}/${sbercloud_obs_bucket_object.netology-logo.key} -acl=public-read
# EOF

#   network {
#     uuid = sbercloud_vpc_subnet.public.id
#   }
# }
