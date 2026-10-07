locals {
  images = var.login_to_ecr ? { for image in var.auto_seed_images : image => image } : {}
}


resource "aws_ecr_repository" "this" {
  name                 = "${var.name}-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-ecr"
  }
}

resource "terraform_data" "login" {
  count      = var.login_to_ecr ? 1 : 0
  depends_on = [aws_ecr_repository.this]

  provisioner "local-exec" {
    command = <<EOT
      # Authenticate Docker with ECR using the specified AWS CLI profile
      docker logout
      aws ecr get-login-password --region ${var.ecr_login_metadata.aws_region} --profile ${var.ecr_login_metadata.aws_profile} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}
    EOT
  }
}

resource "terraform_data" "seed_local_images" {
  for_each = local.images
  depends_on = [aws_ecr_repository.this, terraform_data.login]

  provisioner "local-exec" {
    command = <<EOT
      docker tag ${each.value}:latest ${aws_ecr_repository.this.repository_url}:${each.value}
      docker push ${aws_ecr_repository.this.repository_url}:${each.value}
    EOT
  }
}
