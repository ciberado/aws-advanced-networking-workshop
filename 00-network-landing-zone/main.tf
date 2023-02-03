provider "aws" {
  region = var.region
}

locals {
  name   = "demo-tgw-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-central-1"

  tags = {
    Owner    = "jmoreno"
    Creation = timestamp()
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
