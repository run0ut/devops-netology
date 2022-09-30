################################################################################
# Провайдеры
terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud" # Initialize SberCloud provider
      version = "1.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

################################################################################
# Конфигурация провайдеров 

# SberCloud
provider "sbercloud" {
  auth_url = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3" # Authorization address
  region   = var.sber_region                              # The region where the cloud infrastructure will be deployed

  # Authorization keys
  access_key = var.sber_access_key
  secret_key = var.sber_secret_key
}

# Local resources, such as files
provider "local" {
  # Configuration options
}

