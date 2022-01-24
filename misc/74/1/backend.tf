terraform {
  backend "s3" {
    bucket         = "netology-74"
    key            = "devops-netology/virt-11/74/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "netology-tf-state-locking"
  }
}
