module "network" {
  source = "./modules/network"

  vpc_config = var.vpcs
}

module "eks_clusters" {
  source = "./modules/eks"
  for_each = local.eks_clusters

  name = each.value.name
  k8s_version = each.value.k8s_version
  public_subnet_ids = local.public_subnet_list
  private_subnet_ids = local.private_subnet_list
  vpc_id = module.network.vpc.id

  nodes = each.value.nodes
  fargates = []
}