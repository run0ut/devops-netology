################################################################################
# Image

data "yandex_compute_image" "ubuntu" {
  family = "lamp"
  # image_id = "fd81u0g6sfk13ivcfcrm" # lamp-v20220711
}

################################################################################
# Группа для Network Load Balancer

resource "yandex_compute_instance_group" "n15-net-lb" {
  name                = "n15-net-lb"
  folder_id           = var.yandex_folder_id
  service_account_id  = yandex_iam_service_account.n15.id
  deletion_protection = false

  load_balancer {
    target_group_name = "n15-net-lb"
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 1
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        type     = "network-hdd"
        size     = "20"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network.id
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = false
      ipv6       = false
    }

    network_settings {
      type = "STANDARD"
    }

    metadata = {
      user-data = <<EOF
#!/bin/bash
echo "<html><p>Netwrok Load Balancer</p><p>"`cat /etc/hostname`"</p><img src="https://storage.yandexcloud.net/${yandex_storage_object.netology-logo.bucket}/${yandex_storage_object.netology-logo.key}" alt="Netology logo"></html>" > /var/www/html/index.html
EOF
      ssh-keys  = "ubuntu:${file("../../15.1/yandex/id_rsa_n15.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yandex_compute_default_zone]
  }

  deploy_policy {
    max_unavailable = 3
    max_expansion   = 0
    max_deleting    = 3
    max_creating    = 3
  }
}

################################################################################
# Группа для Application Load Balancer

resource "yandex_compute_instance_group" "n15-app-lb" {
  name                = "n15-app-lb"
  folder_id           = var.yandex_folder_id
  service_account_id  = yandex_iam_service_account.n15.id
  deletion_protection = false

  application_load_balancer {
    target_group_name = "n15-app-lb"
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 1
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        type     = "network-hdd"
        size     = "20"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network.id
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = false
      ipv6       = false
    }

    network_settings {
      type = "STANDARD"
    }

    metadata = {
      user-data = <<EOF
#!/bin/bash
echo "<html><p>Application Load Balancer</p><p>"`cat /etc/hostname`"</p><img src="https://storage.yandexcloud.net/${yandex_storage_object.netology-logo.bucket}/${yandex_storage_object.netology-logo.key}" alt="Netology logo"></html>" > /var/www/html/index.html
EOF
      ssh-keys  = "ubuntu:${file("../../15.1/yandex/id_rsa_n15.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yandex_compute_default_zone]
  }

  deploy_policy {
    max_unavailable = 3
    max_expansion   = 0
    max_deleting    = 3
    max_creating    = 3
  }
}
