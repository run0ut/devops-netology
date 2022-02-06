data "aws_caller_identity" "current" {}

provider "aws" {
  region                  = "eu-north-1"
  profile                 = "default"
  shared_credentials_file = "~/.aws/credentials"
}

####################################################################
# 7.4: ЗАДАНИЕ 3, С МОДУЛЕМ
####################################################################

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.web_instance_for_each_map[terraform.workspace]

  ami           = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  monitoring    = true

  tags = {
    Name        = "Netology 74, task3, ${each.key}"
    Terraform   = "true"
    Environment = "dev"
  }
}

####################################################################
# 7.4: ЗАДАНИЯ 1-2, СКОПИРОВАНО ИЗ 7.3
####################################################################

resource "aws_instance" "ubuntu_count" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  count         = local.web_instance_count_map[terraform.workspace]

  cpu_core_count              = 1
  cpu_threads_per_core        = 2
  monitoring                  = false
  associate_public_ip_address = true

  tags = {
    Name = "ubuntu_count_${terraform.workspace}_${count.index}"
  }
}

resource "aws_instance" "ubuntu_for_each" {
  lifecycle {
    create_before_destroy = true
  }

  ami           = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  for_each      = local.web_instance_for_each_map[terraform.workspace]

  cpu_core_count              = 1
  cpu_threads_per_core        = 2
  monitoring                  = false
  associate_public_ip_address = true

  tags = {
    Name = "Netology 74, ${each.key}"
  }
}

####################################################################
# ПЕРЕМЕННЫЕ И ДАННЫЕ 
####################################################################

data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

locals {
  web_instance_type_map = {
    stage = "t3.micro"
    prod  = "t3.micro" # Free Tier в регионе eu-north-1 только для t3.micro
  }
  web_instance_count_map = {
    stage = 1
    prod  = 2
  }
  web_instance_for_each_map = {
    stage = toset(["s1"])
    prod  = toset(["p1", "p2"])
  }
}
