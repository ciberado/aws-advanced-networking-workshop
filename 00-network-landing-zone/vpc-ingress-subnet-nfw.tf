resource "aws_subnet" "nfw_subnet" {
  count = length(module.vpc_ingress.azs)

  vpc_id            = module.vpc_ingress.vpc_id
  cidr_block        = ["10.10.31.0/24", "10.10.32.0/24"][count.index]
  availability_zone = element(module.vpc_ingress.azs, count.index)
  tags = merge(
    {
      Name = format("${local.name}-nfw-%s", element(module.vpc_ingress.azs, count.index), )
    },
    local.tags
  )
}

resource "aws_route_table" "nfw_rt" {
  vpc_id = module.vpc_ingress.vpc_id

  tags = merge(
    {
      Name = "${local.name}-nfw-rt"
    },
    local.tags
  )
}

resource "aws_route" "nfw_rt_routetonat" {
  route_table_id         = aws_route_table.nfw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc_ingress.natgw_ids[0]

}

resource "aws_route_table_association" "nfwt_rt_ass" {
  count          = length(module.vpc_ingress.azs)
  subnet_id      = element(aws_subnet.nfw_subnet[*].id, count.index)
  route_table_id = aws_route_table.nfw_rt.id
}