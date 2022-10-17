terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.78.2"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "dimploma-bucket"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "YCAJE9DZKigNrEv5obI_OeP-g"
    secret_key = "YCPp4hLAM2RicUjTKOPfLWgOy-10YsHACA1WNj5_"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  # service_account_key_file = "/home/atlantis/key.json"
  cloud_id = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone = var.yandex_compute_default_zone
}
