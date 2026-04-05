module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"

  function_name  = var.project_name
  description    = "Example Lambda function created with Terraform for ${var.project_name} project"
  create_package = false
  image_uri      = "${module.ecr.repository_url}:${var.docker_image_tag}"
  package_type   = "Image"

  attach_policy_jsons    = true
  number_of_policy_jsons = 1
  policy_jsons = [
    data.aws_iam_policy_document.lambda_sqs.json
  ]

  event_source_mapping = {
    sqs = {
      event_source_arn        = module.sqs.queue_arn
      function_response_types = ["ReportBatchItemFailures"]
      scaling_config = {
        maximum_concurrency = 3
        batch_size          = 1
      }
      metrics_config = {
        metrics = ["EventCount"]
      }
    }
  }

  depends_on = [module.ecr]

  tags = {
    Name = var.project_name
    TTL  = 3600
    Date = timestamp()
  }
}
