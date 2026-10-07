variable "name" {
  type = string
}

variable "login_to_ecr" {
  type = bool
}

variable "ecr_login_metadata" {
  type = object({
    aws_profile = string
    aws_region = string 
  })
}

variable "auto_seed_images" {
  type = list(string)
}