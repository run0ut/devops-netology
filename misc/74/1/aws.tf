data "aws_caller_identity" "current" {}

provider "aws" {
  region  = "eu-north-1"
  profile = "default"
}

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

data "aws_region" "current" {}

locals {
  web_instance_type_map = {
    netology-74-stage = "t3.micro"
    netology-74-prod  = "t3.micro" # Free Tier в регионе eu-north-1 только для t3.micro
    stage             = "t3.micro"
    prod              = "t3.micro" # Free Tier в регионе eu-north-1 только для t3.micro
  }
  web_instance_count_map = {
    netology-74-stage = 1
    netology-74-prod  = 2
    stage             = 1
    prod              = 2
  }
  web_instance_for_each_map = {
    netology-74-stage = toset(["s1"])
    netology-74-prod  = toset(["p1", "p2"])
    stage             = toset(["s1"])
    prod              = toset(["p1", "p2"])
  }
}

# resource "null_resource" "example" {}

resource "aws_instance" "ubuntu_count" {
  instance_type = local.web_instance_type_map["${terraform.workspace}"]
  count         = local.web_instance_count_map["${terraform.workspace}"]
  ami           = data.aws_ami.ubuntu.id

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
    Name = "Netology 73, ${each.key}"
  }
}
