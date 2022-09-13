terraform {
  required_providers {
    sbercloud = {
      source = "sbercloud-terraform/sbercloud" # Initialize SberCloud provider
    }
  }
}

# Configure SberCloud provider
provider "sbercloud" {
  auth_url = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3" # Authorization address
  region   = var.sber_region                              # The region where the cloud infrastructure will be deployed

  # Authorization keys
  access_key = var.sber_access_key
  secret_key = var.sber_secret_key
}
