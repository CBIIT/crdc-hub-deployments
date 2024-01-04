# Log Group for ECS Service
resource "aws_cloudwatch_log_group" "extra_task_log_group" {
  for_each   =  var.extratask
  name = "/${var.project}/${var.tier}/${each.value.name}"
}

#task definition
resource "aws_ecs_task_definition" "extra_task_definition" {
  for_each                 = var.extratask
  family                   = "${var.resource_prefix}-${each.value.name}"
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

}

#ecs service
resource "aws_ecs_service" "ecs_service_extra" {
  for_each                 = var.extratask
  name                               = "${var.resource_prefix}-${each.value.name}"
  cluster                  = module.ecs.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.extra_task_definition[each.key].arn
  desired_count                      = each.value.number_container_replicas
  launch_type                        = var.ecs_launch_type
  scheduling_strategy                = var.ecs_scheduling_strategy_extra
  enable_ecs_managed_tags            = true
  enable_execute_command             = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = false
  }
  
}

# adding the metrics to scale in/out
resource "aws_appautoscaling_target" "extratask_autoscaling_target" {
  for_each                 = var.extratask
  max_capacity       = var.scheduled_max_capacity
  min_capacity       = var.scheduled_min_capacity
  resource_id        = "service/${module.ecs.ecs_cluster_arn}/${aws_ecs_service.ecs_service_extra[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# adding autoscaling policy
resource "aws_appautoscaling_policy" "sqs_scaling_policy" {
  for_each                 = var.policy
  name         = "${var.resource_prefix}-${each.value.name}"
  scaling_target_id = aws_appautoscaling_target.extratask_autoscaling_target[each.key].id
  policy_type            = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metric_dimension {  
        name = each.value.name
        value = "/${var.project}/${var.tier}/${each.value.name}.fifo"
      }
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace = "AWS/SQS"
      statistic = "Minimum"
      unit  = "Count"
    }
    target_value = 0.5
  }
}
