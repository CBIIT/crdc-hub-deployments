#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


#policy to allow BE service to generate embedded URLs for QuickSight dashboards
data "aws_iam_policy_document" "quicksight_embed_policy" {
  statement {
    effect = "Allow"
    actions = [
      "quicksight:GenerateEmbedUrlForAnonymousUser",
      "quicksight:GenerateEmbedUrlForRegisteredUser",
      "quicksight:GetDashboardEmbedUrl"
    ]
#    resources = ["*"]
    resources = ["arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dashboard/*"]
  }
}


# added name of execute ECS roles
data "aws_iam_role" "quicksight_task_role" {
  name = local.datasync_task_role_name
}

data "aws_iam_role" "quicksight_task_execution_role" {
  name = local.datasync_task_execution_role_name
}
