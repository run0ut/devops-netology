# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
# Узнать командой: yc config list | grep cloud-id
variable "yandex_cloud_id" {
  default = "b1g19qmh5o80gm94ufu8"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
# Узнать командой: yc config list | grep folder-id
variable "yandex_folder_id" {
  default = "b1g01oeuesd31te4bm64"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды: yc compute image list --format yaml | grep -w id: 
variable "centos-7-base" {
  default = "fd892lo8d01isur3s0q2"
}
