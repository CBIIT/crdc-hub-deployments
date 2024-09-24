variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "name of the project"
  type        = string
}

variable "tier" {
  type = string
}
variable "tags" {
  description = "tags to associate with this instance"
  type        = map(string)
}

variable "ecs_scheduled_tags" {
  type        = map(string)
}

variable "task_execution_role_arn" {
  type        = string
}

variable "task_role_arn" {
  type        = string
}

variable "cron_schedule" {
  type        = string
}

variable "cluster_arn" {
  type        = string
}
 
variable "task_count" {
  type = number
  default = 1
}

variable "ecs_network_mode" {
  description = "ecs network mode - bridge,host,awsvpc"
  type        = string
  default     = "awsvpc"
}

variable "security_group_ids" {
  type    = list(string)
 # default = ["sg-0af8bf5fca57a6be2"]
}

variable "subnet_ids" {
  type = list(string)
}

#variable "ecs_launch_type" {
#  description = "ecs launch type - FARGATE or EC2"
#  type        = string
#  default     = "FARGATE"
#}

#variable "ecs_scheduling_strategy_extra" {
#  description = "ecs scheduling strategy"
#  type        = string
#  default     = "REPLICA"
#}

#variable "role_arn_autoscaling" {
#  type        = string
#}

variable "scheduledtask" {
  type = map(object({
    name      = string
    image_url = string
    cpu       = number
    memory    = number
  }))
}
