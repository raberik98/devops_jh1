output "vpc" {
  value = aws_vpc.this
}

output "name" {
  value = var.vpc_config.name
}

output "all_subnets" {
  value = aws_subnet.this
}

output "public_subnets" {
  value = { for sn in local.public_subnets: sn.name => aws_subnet.this[sn.name] if local.subnets[sn.name].type == "public" }
}

output "private_subnets" {
  value = { for sn in local.private_subnets: sn.name => aws_subnet.this[sn.name] if local.subnets[sn.name].type == "private" }
}