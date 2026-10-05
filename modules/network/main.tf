locals {
  name       = var.vpc_config.name
  cidr_range = var.vpc_config.cidr_range
  tags       = var.vpc_config.tags

  subnets         = { for subnet in var.vpc_config.subnets : subnet.name => subnet }
  public_subnets  = { for name, config in local.subnets : name => config if config.type == "public" }
  private_subnets = { for name, config in local.subnets : name => config if config.type == "private" }
}

resource "aws_vpc" "this" {
  cidr_block           = local.cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.tags,
    { Name = local.name }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    { Name = "${local.name}-igw" }
  )
}


resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_range
  availability_zone = each.value.AZ  

  tags = merge(
    each.value.tags,
    { Name = each.value.name }
  )
}



resource "aws_route_table" "public" {
  count = length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    local.tags,
    { Name = "${local.name}-rt-public" }
  )
}

# Private route table (routes all non-local traffic to NAT Gateway)
resource "aws_route_table" "private" {
  count = length(local.private_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    local.tags,
    { Name = "${local.name}-rt-private" }
  )
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private[0].id
}

# ----------------------------------------------------------------------
# NAT GATEWAY (only if both public and private subnets exist)
# ----------------------------------------------------------------------
resource "aws_eip" "this" {

  domain = "vpc"

  tags = merge(
    local.tags,
    { Name = "${local.name}-nat-eip" }
  )
}

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.this["public1"].id 

  tags = merge(
    local.tags,
    { Name = "${local.name}-nat" }
  )

  # Ensure the IGW and route table are ready
  depends_on = [aws_internet_gateway.this]
}
