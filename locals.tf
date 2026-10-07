locals {
  subnet_ids   = [ for sn in module.network.all_subnets : sn.id ]
  public_subnet_list = [ for sn in module.network.public_subnets : sn.id ]
  private_subnet_list = [ for sn in module.network.private_subnets : sn.id ]


  eks_clusters = { for cluster in var.eks_clusters : cluster.name => cluster }
  ecr_registries = { for reg in var.ecr_registries : reg.name => reg }
}
