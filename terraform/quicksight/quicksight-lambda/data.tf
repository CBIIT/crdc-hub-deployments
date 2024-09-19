#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


# policy for lambda func to  assume role
data "aws_iam_policy_document" "lambda_quicksight_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
