terraform {
  backend "remote" {
    organization = "DevopsNetologyLearning"
    workspaces {
      prefix = "netology-74-"
    }
  }
}
