## Add tgw route 0.0.0.0/0 -> ingress vpc


module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.1"

  name            = local.name
  description     = "My TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  transit_gateway_cidr_blocks = ["10.99.0.0/24"]

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = true

  # When "true", allows service discovery through IGMP
  enable_mutlicast_support = false

  share_tgw = false

  vpc_attachments = {
    vpc_ingress = {
      vpc_id       = module.vpc_ingress.vpc_id
      subnet_ids   = module.vpc_ingress.private_subnets
      dns_support  = true
      ipv6_support = false
      tags = merge(local.tags, {
        Name : "${local.name}-tgw-attachment-ingress"
      })
    },
    vpc_inner = {
      vpc_id     = module.vpc_inner.vpc_id
      subnet_ids = module.vpc_inner.private_subnets
      dns_support = true
      ipv6_support = false
      tags = merge(local.tags, {
        Name : "${local.name}-tgw-attachment-inner"
      })
    },
  }

  ram_allow_external_principals = true
  ram_principals                = [307990089504]

  tags = local.tags
}
