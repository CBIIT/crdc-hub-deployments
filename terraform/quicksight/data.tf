#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


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

#policy to allow the role power-user-quicksight-iam-role to invoke the lambda function (to use athena data source connects to mongodb)- fixed by adding the policy below to the role
data "aws_iam_policy_document" "quicksight_role_policy" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
#      for lambda-function-name in var.lambda-funtions : "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${lambda-function-name}"
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
    ]
  }  
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



#move this to quicksight-embed - policy to allow BE service to generate embedded URLs for QuickSight dashboards
#data "aws_iam_policy_document" "quicksight_embed_policy" {
#  statement {
#    effect = "Allow"
#    actions = [
#      "quicksight:GenerateEmbedUrlForAnonymousUser",
#      "quicksight:GenerateEmbedUrlForRegisteredUser"
#    ]
#    resources = ["*"]
#  }
#}


# added name of execute ECS roles
#data "aws_iam_role" "quicksight_task_role" {
#  name = local.datasync_task_role_name
#}

#data "aws_iam_role" "quicksight_task_execution_role" {
#  name = local.datasync_task_execution_role_name
#}
