module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "5.2.1"

  name       = var.project_name
  create_dlq = true

  tags = {
    Name = var.project_name
    TTL  = 3600
    Date = timestamp()
  }
}
