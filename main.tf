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
