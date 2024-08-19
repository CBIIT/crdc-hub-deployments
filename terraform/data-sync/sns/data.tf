#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# policy for eventbridge to SNS
data "aws_iam_policy_document" "assume_role_sns_policy" {
  statement {
  actions = ["sts:AssumeRole"]
  principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge_to_sns_policy" {
  statement {
    effect = "Allow"
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.datasync_status_topic.arn]
  }
}
