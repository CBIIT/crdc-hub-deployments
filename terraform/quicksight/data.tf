#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#policy for datasync task


# policy for the quicksight to assume role
data "aws_iam_policy_document" "quicksight_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["quicksight.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "quicksight_pass_role_policy" {
  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["quicksight.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }
}
