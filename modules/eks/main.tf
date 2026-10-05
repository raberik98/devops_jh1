locals {
  node_groups = { for ng in var.nodes : ng.name => ng }
}

resource "aws_security_group" "eks_cluster" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow worker nodes to communicate with control plane"
  }

  tags = {
    Name = "${var.name}-eks-cluster-sg"
  }
}

# Master node only
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.k8s_version

  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids         = concat(var.private_subnet_ids, var.public_subnet_ids)
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}


# Addons
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"

  depends_on = [ aws_eks_node_group.worker_node_group ]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

# Worker node
resource "aws_eks_node_group" "worker_node_group" {
  for_each = local.node_groups

  cluster_name = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = var.private_subnet_ids


  scaling_config {
    desired_size = each.value.default_scale
    max_size     = each.value.max_scale
    min_size     = each.value.min_scale
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_policy,
  ]
}

