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
      "logs:*",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "sagemaker_permission_admin_role_policy_doc" {
  statement {
    effect  = "Allow"
    actions = [
      "sagemaker:*"
    ]

    resources = [
      "arn:aws:sagemaker:*:*:domain/*",
      "arn:aws:sagemaker:*:*:user-profile/*",
      "arn:aws:sagemaker:*:*:app/*",
      "arn:aws:sagemaker:*:*:flow-definition/*"
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "iam:GetRole",
      "servicecatalog:*"
    ]
    resources = ["*"]
  }
}
