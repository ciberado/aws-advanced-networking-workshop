# TODO: tabla de rutas 10.20.0.0/0 a tgw
# TODO: separa subnets para los attachments
# TODO: separa subnets para anfw

locals {

  ingressTags = merge({
    Connectivity : "ingress"
  }, local.tags)

}

module "vpc_ingress" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-${local.ingressTags.Connectivity}-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  public_subnets  = ["10.10.11.0/24", "10.10.12.0/24"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.ingressTags
}

resource "aws_security_group" "app1_sg" {
  name        = "appsg"
  description = "Allow http traffic"
  vpc_id      = module.vpc_ingress.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.ingressTags
}

resource "aws_instance" "app1_ec2" {
  ami           = data.aws_ami.app1_ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = module.vpc_ingress.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.app1_sg.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name

  user_data = <<-EOF
#!/bin/sh
sudo apt update
sudo apt install nginx -y
EOF

  tags = merge({
    Name = "app-${local.ingressTags.Connectivity}"
  }, local.ingressTags)

}