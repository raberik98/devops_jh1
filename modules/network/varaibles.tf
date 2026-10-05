variable "vpc_config" {
  type = object({
    name = string
    tags = map(string)
    cidr_range = string

    subnets = list(object({
      name = string
      cidr_range = string
      type = string
      tags = map(string)
      AZ = string
    }))
  })
}