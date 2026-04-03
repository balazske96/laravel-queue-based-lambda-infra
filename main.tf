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

module "s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  count         = var.should_deploy ? 1 : 0
  bucket        = "aws-laravel-functions-bucket"
  force_destroy = true
}
