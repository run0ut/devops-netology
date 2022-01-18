terraform {
  backend "remote" {
    organization = "DevopsNetologyLearning"
    workspaces {
      name = "devops-netology-terraform-task"
    }
  }
}
