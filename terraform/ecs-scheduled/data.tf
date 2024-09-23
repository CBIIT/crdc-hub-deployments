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
