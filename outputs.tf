output "vpc_info_markdown" {
  value = templatefile("${path.module}/templates/network.tftemplate", {
    vpc_name        = module.network.name
    public_subnets  = module.network.public_subnets
  })
}
