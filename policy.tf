data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.should_deploy ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

data "aws_iam_policy_document" "github_oidc_assume_role" {
  count = var.should_deploy ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.trusted_repository]
    }
  }
}

resource "aws_iam_role" "ci_ecr_push" {
  name               = "CIEcrPushRole"
  count              = var.should_deploy ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role[0].json
}

data "aws_iam_policy_document" "ci_ecr_push" {
  count = var.should_deploy ? 1 : 0

  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [format(
      "arn:%s:ecr:%s:%s:repository/%s",
      data.aws_partition.current.partition,
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      "aws-laravel-functions-basic"
    )]
  }
}

resource "aws_iam_role_policy" "ci_ecr_push" {
  name   = "CIEcrPushPolicy"
  count  = var.should_deploy ? 1 : 0
  role   = aws_iam_role.ci_ecr_push[0].id
  policy = data.aws_iam_policy_document.ci_ecr_push[0].json
}
