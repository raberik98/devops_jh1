variable "aws_region" {
  type = string
}

variable "awscli_profile" {
  type = string
}

variable "vpcs" {
  type = object({
    name       = string
    tags       = map(string)
    cidr_range = string

    subnets = list(object({
      name       = string
      cidr_range = string
      type       = string
      tags       = map(string)
      AZ         = string
    }))
  })
}

variable "eks_clusters" {
  description = "value"
  type = list(object({
    name        = string
    k8s_version = string

    nodes = list(object({
      name     = string
      ec2_type = string

      default_scale = number
      max_scale     = number
      min_scale     = number
    }))
    fargates = list(bool) # TODO
  }))
}
