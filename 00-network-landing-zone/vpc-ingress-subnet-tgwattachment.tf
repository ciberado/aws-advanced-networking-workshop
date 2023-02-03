resource "aws_subnet" "att_subnet" {
  count = length(module.vpc_ingress.azs)

  vpc_id            = module.vpc_ingress.vpc_id
  cidr_block        = ["10.10.21.0/24", "10.10.22.0/24"][count.index]
  availability_zone = element(module.vpc_ingress.azs, count.index)
  tags = merge(
    {
      Name = format("${local.name}-tgwwattachment-%s", element(module.vpc_ingress.azs, count.index), )
    },
    local.tags
  )
}

resource "aws_route_table" "attachment_rt" {
  vpc_id = module.vpc_ingress.vpc_id

  tags = merge(
    {
      Name = "${local.name}-tgwwattachment-rt"
    },
    local.tags
  )
}

resource "aws_route" "attachment_rt_routetonat" {
  route_table_id         = aws_route_table.attachment_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc_ingress.natgw_ids[0]

}

resource "aws_route_table_association" "attachment_rt_ass" {
  count          = length(module.vpc_ingress.azs)
  subnet_id      = element(aws_subnet.att_subnet[*].id, count.index)
  route_table_id = aws_route_table.attachment_rt.id
}