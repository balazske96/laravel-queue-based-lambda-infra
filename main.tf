module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  count  = var.should_deploy ? 1 : 0

  function_name = "aws-laravel-functions-basic"
  description   = "Example Lambda function created with Terraform"
  handler       = "example.handler"
  runtime       = "nodejs24.x"

  source_path = "./example.js"

  tags = {
    Name = "aws-laravel-functions-basic"
    TTL  = 3600
    Date = timestamp()
  }
}

module "ecr" {
  source     = "terraform-aws-modules/ecr/aws"
  count      = var.should_deploy ? 1 : 0
  depends_on = [aws_iam_role.ci_ecr_push]

  repository_name = "aws-laravel-functions-basic"
  repository_read_write_access_arns = [
    aws_iam_role.ci_ecr_push[0].arn
  ]

  # This lifecycle policy keeps only the last image in the repository, and expires the rest. Adjust it according to your needs.
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 1 image",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name = "aws-laravel-functions-basic"
    TTL  = 3600
    Date = timestamp()
  }
}
