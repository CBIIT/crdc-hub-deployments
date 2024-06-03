data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "current" {
  id = var.vpc_id
}

data "aws_iam_policy_document" "sagemaker_instance_nb_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sagemaker_execution_role_policy_doc" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "sagemaker:*",
      "cloudwatch:*",
      "logs:*"
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

