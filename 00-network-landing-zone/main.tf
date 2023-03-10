provider "aws" {
  region = var.region
}

resource "random_pet" "suffix" {
}

locals {
  name   = "demoingress-${replace(random_pet.suffix.id, "-", "")}"
  region = "eu-central-1"

  tags = {
    Owner    = "jmoreno"
  }
}

data "aws_ami" "app1_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] /* Ubuntu */

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
