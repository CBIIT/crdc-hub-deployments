#get account info
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


# name of execute ECS role
data "aws_iam_role" "schedule_ecs_task_role" {
  name = local.ecs_task_role_name
}

data "aws_iam_role" "schedule_ecs_task_execution_role" {
  name = local.execution_task_role_name
}

# policy for the eventbridge role to assume evemts.amazonaws.com
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
  actions = ["sts:AssumeRole"]
  principals {
    type        = "Service"
    identifiers = ["events.amazonaws.com"]
    }
  }
}

# policy to allow eventbridge to run the ecs task
data "aws_iam_policy_document" "eventbridge_run_ecs_policy" {
  statement {
    effect = "Allow"
    actions = ["ecs:RunTask"]
    resources = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/*"]
  }
}
