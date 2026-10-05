variable "name" {
  type = string
}

# variable "role_arn" {
#   type = string
# }

variable "k8s_version" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "nodes" {
  type = list(object({
    name = string
    ec2_type = string

    default_scale = number
    max_scale = number
    min_scale = number
  }))
}

variable "fargates" {
  type = list(bool)
}

variable "vpc_id" {
  type = string
}
