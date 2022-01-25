terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region                  = "eu-north-1"
  profile                 = "default"
  shared_credentials_file = "~/.aws/credentials"
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "netology-74"
  acl    = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = false
  }
}

resource "aws_dynamodb_table" "netology_terraform_locks" {
  name         = "netology-tf-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}