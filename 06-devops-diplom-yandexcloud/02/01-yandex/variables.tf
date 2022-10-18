################################################################################
# Yandex IDs
variable "yandex_cloud_id" {
  default = ""
}

variable "yandex_folder_id" {
  default = ""
}

variable "yandex_compute_default_zone" {
  default = ""
}

################################################################################
# DockerHub
variable "dockerhub_login" {
  default = ""
}

variable "dockerhub_password" {
  default   = ""
  sensitive = true
}

################################################################################
# GitHub
variable "github_personal_access_token" {
  default   = ""
  sensitive = true
}

variable "github_webhook_secret" {
  default = "diplomasecret"
}

variable "github_login" {
  default = ""
}
