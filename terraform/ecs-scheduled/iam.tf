#attach the IAM permission to the ECS execute role to write to cloudwatch logs
resource "aws_iam_policy_attachment" "ecs_cloudwatch_log_write_atach" {
  name = "cloudwatch-log-policy-attach"
  roles  = [data.aws_iam_role.schedule_ecs_task_role.name,data.aws_iam_role.schedule_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# attach the policy to allow cloudwatch event to trigger ECS task
resource "aws_iam_policy_attachment" "ecs_cloudwatch_event_trigger_atach" {
  name = "event-trigger-policy-attach"
  roles  = [data.aws_iam_role.schedule_ecs_task_role.name,data.aws_iam_role.schedule_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

#attach the policy to allow  EventBridge to send messages to the SQS Queue to troubleshoot
resource "aws_iam_policy_attachment" "ecs_sqs_troubleshoot_attach" {
  name = "ecs_sqs_troubleshoot_attach"
  roles  = [data.aws_iam_role.schedule_ecs_task_role.name,data.aws_iam_role.schedule_ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# create eventsbridge role to run ecstask
resource "aws_iam_role" "eventsbridge-ecs-task-role" {
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_policy.json
  name = "power-user-${terraform.workspace}-eventsbridge-ecs-task-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

# create iam policy for the eventsbridge role
resource "aws_iam_policy" "eventsbridge-policy" {
  name = "power-user-${terraform.workspace}-eventsbridge-policy"
  policy = data.aws_iam_policy_document.eventbridge_run_ecs_policy.json
}

# attach policy to the eventbridge role
resource "aws_iam_role_policy_attachment" "eventsbridge-policy-attach" {
  role = aws_iam_role.eventsbridge-ecs-task-role.name
  policy_arn = aws_iam_policy.eventsbridge-policy.arn  
}

# attach extra policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch_full_atach" {
  role = aws_iam_role.eventsbridge-ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_full_attach" {
  role = aws_iam_role.eventsbridge-ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_events_attach" {
  role = aws_iam_role.eventsbridge-ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
