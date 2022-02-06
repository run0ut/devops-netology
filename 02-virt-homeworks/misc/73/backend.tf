terraform {
  backend "s3" {
    bucket         = "netology-73"
    key            = "devops-netology/virt-11/73/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "netology-tf-state-locking"
  }
}
