#attach the IAM permission to the ECS execute role to write to cloudwatch logs
resource "aws_iam_policy_attachment" "ecs_cloudwatch_log_write_atach" {
  name = "cloudwatch-log-policy-attach"
  roles  = [data.aws_iam_role.schedule_ecs_task_role.name,data.aws_iam_role.schedule_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# attach the policy to allow cloudwatch event to trigger ECS task
resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_event_trigger_atach" {
  name = "event-trigger-policy-attach"
  roles  = [data.aws_iam_role.schedule_ecs_task_role.name,data.aws_iam_role.schedule_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
