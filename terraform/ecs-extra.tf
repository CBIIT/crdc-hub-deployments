# Log Group for ECS Service
resource "aws_cloudwatch_log_group" "extra_task_log_group" {
  for_each   =  var.extratask
  name = "/${var.project}/${var.tier}/${each.value.name}"
  retention_in_days = 120
}

#task definition
resource "aws_ecs_task_definition" "extra_task_definition" {
  for_each                 = var.extratask
  family                   = "${var.project}-${var.tier}-${each.value.name}"
  network_mode             = var.ecs_network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = module.ecs.ecs_task_execution_role_arn
  task_role_arn            = module.ecs.ecs_task_role_arn

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
            
            awslogs-group = aws_cloudwatch_log_group.extra_task_log_group[each.value.name].name
            awslogs-region = var.aws_region
            
          }
        }
    }
  ])

  tags = var.ecs_extra_tags
}

#ecs service
resource "aws_ecs_service" "ecs_service_extra" {
  for_each                 = var.extratask
  name                     = "${var.project}-${var.tier}-${each.value.name}"
  cluster                  = module.ecs.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.extra_task_definition[each.key].arn
  desired_count                      = each.value.number_container_replicas
  launch_type                        = var.ecs_launch_type
  scheduling_strategy                = var.ecs_scheduling_strategy_extra
  enable_ecs_managed_tags            = true
  enable_execute_command             = true
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = false
  }
  tags = var.ecs_extra_tags  
}

# adding the update and get status of the protection task policy to the ecs exec role 

data "aws_iam_role" "protection_ecs_task_role" {
  name = local.task_role_name
  depends_on = [module.ecs]
}

data "aws_iam_policy_document" "protection_ecs_task" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateTaskProtection",
      "ecs:GetTaskProtection"
    ]
    resources = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/${module.ecs.ecs_cluster_name}/*"]
  }
}

#use the document in the policy
resource "aws_iam_policy" "protection_ecs_task_policy" {
  name    = "power-user-${var.tier}-protection-ecs-task-policy"
  policy = data.aws_iam_policy_document.protection_ecs_task.json
}

#attach the iam protection policy to the ecs task role
resource "aws_iam_policy_attachment" "attach_protection_ecs_task" {
  name = "protection-ecs-task-policy-attach"
  roles = [data.aws_iam_role.protection_ecs_task_role.name]
  policy_arn = aws_iam_policy.protection_ecs_task_policy.arn
}

# adding the metrics to scale in/out
resource "aws_appautoscaling_target" "extratask_autoscaling_target" {
  for_each                 = var.extratask
  max_capacity       = each.value.scheduled_max_capacity
  min_capacity       = each.value.scheduled_min_capacity
  #resource_id        = "service/${module.ecs.ecs_cluster_arn}/${aws_ecs_service.ecs_service_extra[each.key].name}"
  resource_id        = "service/${module.ecs.ecs_cluster_name}/${aws_ecs_service.ecs_service_extra[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn      = var.role_arn_autoscaling
  depends_on = [aws_ecs_service.ecs_service_extra]
}

# adding autoscaling policy for scale-out using step scaling policy
resource "aws_appautoscaling_policy" "sqs_scaling_out_policy" {
  for_each                 = var.policy
  name         = "${var.project}-${var.tier}-${each.value.name}-scale-out"
  #scaling_target_id = aws_appautoscaling_target.extratask_autoscaling_target[each.key].id
  resource_id        = aws_appautoscaling_target.extratask_autoscaling_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.extratask_autoscaling_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.extratask_autoscaling_target[each.key].service_namespace
  policy_type            = "StepScaling"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown = 300  # in sec
    metric_aggregation_type = "Minimum"
    step_adjustment {
      metric_interval_lower_bound = each.value.lower1 
      metric_interval_upper_bound = each.value.upper1
      scaling_adjustment         = each.value.scale1
    }

    step_adjustment {
      metric_interval_lower_bound = each.value.lower2
      scaling_adjustment         = each.value.scale2
    }
  }
}

#adding cloudwatch alarm for scale-out
resource "aws_cloudwatch_metric_alarm" "alarm_sqs_scaling_out" {
  for_each                 = var.policy
  alarm_name = "${var.project}-${var.tier}-${each.value.name}-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = 10
  statistic = "Minimum"
  threshold = 1
#  action_enabled = true
  alarm_actions = [aws_appautoscaling_policy.sqs_scaling_out_policy[each.key].arn]
  dimensions = {
    QueueName = "${var.project}-${var.tier}-${each.value.name}.fifo"
  }
}

#adding autoscaling policy for scale-in
resource "aws_appautoscaling_policy" "sqs_scaling_in_policy" {
  for_each                 = var.policy
  name         = "${var.project}-${var.tier}-${each.value.name}-scale-in"
  #scaling_target_id = aws_appautoscaling_target.extratask_autoscaling_target[each.key].id
  resource_id        = aws_appautoscaling_target.extratask_autoscaling_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.extratask_autoscaling_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.extratask_autoscaling_target[each.key].service_namespace
  policy_type            = "StepScaling"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown = 10 # in sec
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment         = -1
    }
  }
}

#adding cloudwatch alarm for scale-in
resource "aws_cloudwatch_metric_alarm" "alarm_sqs_scaling_in" {
  for_each                 = var.policy
  alarm_name = "${var.project}-${var.tier}-${each.value.name}-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = 10
  statistic = "Maximum"
  threshold = 0
#  action_enabled = true
  alarm_actions = [aws_appautoscaling_policy.sqs_scaling_in_policy[each.key].arn]
  dimensions = {
    QueueName = "${var.project}-${var.tier}-${each.value.name}.fifo"
  }
}
