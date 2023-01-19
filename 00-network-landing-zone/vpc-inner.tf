# TODO: tabla de rutas 0.0.0.0/0 a tgw
# TODO: separa subnets para los attachments

locals {
  innerTags = merge({
    Connectivity : "inner"
  }, local.tags)

}

module "vpc_inner" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-${local.innerTags.Connectivity}-vpc"
  cidr = "10.20.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]

  enable_ipv6 = false

  enable_dns_support  = true
  enable_dns_hostnames = true
  

  tags = local.innerTags
}

resource "aws_security_group" "vpc_inner_endpoints_sg" {
  name        = "endpoints_sg"
  description = "Allow https traffic"
  vpc_id      = module.vpc_inner.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = local.innerTags
}


module "vpc_inner_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.19.0"

  vpc_id             = module.vpc_inner.vpc_id
  security_group_ids = [aws_security_group.vpc_inner_endpoints_sg.id]

  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc_inner.private_subnets
      security_group_ids  = [aws_security_group.vpc_inner_endpoints_sg.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc_inner.private_subnets
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc_inner.private_subnets
    }    
  }

  tags = local.innerTags
  
}


resource "aws_security_group" "app2_sg" {
  name        = "appsg"
  description = "Allow http traffic"
  vpc_id      = module.vpc_inner.vpc_id

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

  tags = local.innerTags
}

resource "aws_instance" "app2_ec2" {
  ami           = data.aws_ami.app1_ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = module.vpc_inner.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.app2_sg.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name

  user_data = <<-EOF
#!/bin/sh
sudo apt update
sudo apt install nginx -y
EOF

  tags = merge({
    Name = "app-${local.innerTags.Connectivity}"
  }, local.innerTags)
  
    
}