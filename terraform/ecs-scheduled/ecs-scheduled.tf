# Log Group for ECS Service
resource "aws_cloudwatch_log_group" "scheduled_task_log_group" {
  for_each   =  var.scheduledtask
  name = "/${var.project}/${var.tier}/${each.value.name}"
  retention_in_days = 150
}

#task definition
resource "aws_ecs_task_definition" "scheduled_task_definition" {
  for_each                 = var.scheduledtask
  family                   = "${var.project}-${var.tier}-${each.value.name}"
  network_mode             = var.ecs_network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = each.value.image_url
      essential = true,
      firelensConfiguration = {
          type = "fluentbit"
        }
     
     logConfiguration = {
          logDriver      = "awsfirelens"
          options =  {
            
            awslogs-group = aws_cloudwatch_log_group.scheduled_task_log_group[each.value.name].name
            awslogs-region = var.aws_region
            
          }
        }
    }
  ])
  tags = var.ecs_scheduled_tags
}

# create cloudwatch event rule for the schedule
resource "aws_cloudwatch_event_rule" "scheduled_rule" {
  name        = local.schedule_task_rule
  description = "Run ECS Fargate task every day"
  #schedule_expression = "rate(1 day)"
  #schedule_expression = "cron(0 0 * * ? *)"
  schedule_expression = var.cron_schedule
}

# create Target the ECS Task to run on a schedule
resource "aws_cloudwatch_event_target" "ecs_task_target" {
  for_each                 = var.scheduledtask
  rule      = aws_cloudwatch_event_rule.scheduled_rule.name
  arn       = var.cluster_arn
  role_arn  = var.task_execution_role_arn
  ecs_target {
    #task_definition_arn = aws_ecs_task_definition.scheduled_task_definition[each.key].arn
    task_definition_arn = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/${var.task_definition_name}"
    task_count          = var.task_count
    launch_type         = "FARGATE"
    network_configuration {
      subnets         = var.subnet_ids
      security_groups = var.security_group_ids
      assign_public_ip = false
    }
    platform_version  = "LATEST"
  }
}

