resource "aws_ecr_repository" "terraform-upgrader" {
  name = "terraform-upgrader"
  tags = merge(
    local.common_tags,
    { DockerHub : "dwpdigital/terraform-upgrader" }
  )
}

resource "aws_ecr_repository_policy" "terraform-upgrader" {
  repository = aws_ecr_repository.terraform-upgrader.name
  policy     = data.terraform_remote_state.management.outputs.ecr_iam_policy_document
}

output "ecr_example_url" {
  value = aws_ecr_repository.terraform-upgrader.repository_url
}
