# This role enables Lambda functions to read and delete SQS messages.
data "aws_iam_policy_document" "lambda_sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [
      module.sqs.queue_arn,
      module.sqs.dead_letter_queue_arn,
    ]
  }
}
