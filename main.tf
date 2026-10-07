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
  configure_local_kubectl = each.value.configure_local_kubectl
  kubectl_config = each.value.configure_local_kubectl ? { aws_region = var.aws_region, aws_cli_profile = var.awscli_profile } : {}

  nodes = each.value.nodes
  fargates = []
}

module "aws_ecr" {
  source = "./modules/ecr"

  for_each = local.ecr_registries

  name = each.key
  login_to_ecr = each.value.auto_local_login
  ecr_login_metadata = each.value.auto_local_login ? { aws_region = var.aws_region, aws_profile = var.awscli_profile } : {}
  auto_seed_images = each.value.images
}