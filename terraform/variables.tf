# global variables
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

variable "vpc_id" {
  description = "vpc id to to launch the ALB"
  type        = string
}

variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}

variable "private_subnet_ids" {
  description = "Provide list private subnets to use in this VPC. Example 10.0.10.0/24,10.0.11.0/24"
  type        = list(string)
}

variable "microservices" {
  type = map(object({
    name                      = string
    port                      = number
    health_check_path         = string
    priority_rule_number      = number
    image_url                 = string
    cpu                       = number
    memory                    = number
    path                      = list(string)
    number_container_replicas = number
  }))
}

variable "domain_name" {
  description = "domain name for the application"
  type        = string
}

#variable "create_opensearch_cluster" {
#  description = "choose to create opensearch cluster or not"
#  type        = bool
#  default     = false
#}

#variable "create_db_instance" {
#  description = "set this value if you want create db instance"
#  default     = false
#  type        = bool
#}

variable "target_account_cloudone" {
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default     = true
}

variable "iam_prefix" {
  type        = string
  default     = "power-user"
  description = "nci iam power user prefix"
}

# ALB
variable "certificate_domain_name" {
  description = "domain name for the ssl cert"
  type        = string
}

variable "internal_alb" {
  description = "is this alb internal?"
  default     = false
  type        = bool
}

variable "lb_type" {
  description = "Type of loadbalancer"
  type        = string
  default     = "application"
}


variable "public_subnet_ids" {
  description = "Provide list of public subnets to use in this VPC. Example 10.0.1.0/24,10.0.2.0/24"
  type        = list(string)
}

variable "s3_force_destroy" {
  description = "force destroy bucket"
  default     = true
  type        = bool
}

# Cloudfront
#variable "alarms" {
#  description = "alarms to be configured"
#  type        = map(map(string))
#}

#variable "cloudfront_distribution_bucket_name" {
#  description = "specify the name of s3 bucket for cloudfront"
#  type        = string
#}

#variable "cloudfront_log_path_prefix_key" {
#  description = "path prefix to where cloudfront send logs to s3 bucket"
#  type        = string
#  default     = "cloudfront/logs"
#}

#variable "cloudfront_origin_acess_identity_description" {
#  description = "description for OAI"
#  type        = string
#  default     = "cloudfront origin access identify for s3"
#}

#variable "cloudfront_slack_channel_name" {
#  type        = string
#  description = "cloudfront slack name"
#}

#variable "create_cloudfront" {
#  description = "create cloudfront or not"
#  type        = bool
#  default     = false
#}

#variable "create_files_bucket" {
#  description = "indicate if you want to create files bucket or use existing one"
#  type        = bool
#  default     = false
#}

#variable "slack_secret_name" {
#  type        = string
#  description = "name of cloudfront slack secret"
#}

# ECR
variable "create_ecr_repos" {
  type        = bool
#  default     = false
  description = "choose whether to create ecr repos or not"
}

#variable "create_env_specific_repo" {
#  description = "choose to create environment specific repo. Example bento-dev-frontend"
#  type        = bool
#  default     = false
#}

variable "ecr_repo_names" {
  description = "list of repo names"
  type        = list(string)
}

# ECS
#variable "add_opensearch_permission" {
#  type        = bool
#  default     = false
#  description = "choose to create opensearch permission or not"
#}

variable "allow_cloudwatch_stream" {
  type        = bool
  default     = true
  description = "allow cloudwatch stream for the containers"
}

variable "application_subdomain" {
  description = "subdomain of the app"
  type        = string
}

# Instance Profile
variable "create_instance_profile" {
  type        = bool
  default     = false
  description = "set to create instance profile"
}

# Monitoring
variable "sumologic_access_id" {
  type        = string
  description = "Sumo Logic Access ID"
}
variable "sumologic_access_key" {
  type        = string
  description = "Sumo Logic Access Key"
  sensitive   = true
}

# Newrelic Metrics
#variable "account_level" {
#  type        = string
#  description = "whether the account is prod or non-prod"
#}

#variable "create_newrelic_pipeline" {
#  type        = bool
#  description = "whether to create the newrelic pipeline"
#  default = false
#}

#variable "newrelic_account_id" {
#  type        = string
#  description = "Newrelic Account ID"
##  sensitive   = true
#}

#variable "newrelic_api_key" {
#  type        = string
#  description = "Newrelic API Key"
#  sensitive   = true
#}

#variable "newrelic_s3_bucket" {
#  type        = string
#  description = "the bucket to use for failed metrics"
#}

#variable "program" {
#  type        = string
##  description = "the program name"
#  default     = "crdc"
#}

# Opensearch
#variable "automated_snapshot_start_hour" {
#  description = "hour when automated snapshot to be taken"
#  type        = number
#  default     = 23
#}

variable "create_cloudwatch_log_policy" {
  description = "Due cloudwatch log policy limits, this should be option, we can use an existing policy"
  default     = false
  type        = bool
}

#variable "create_os_service_role" {
#  type        = bool
#  default     = false
#  description = "change this value to true if running this script for the first time"
#}

#variable "multi_az_enabled" {
#  description = "set to true to enable multi-az deployment"
#  type        = bool
#  default     = false
#}

#variable "opensearch_ebs_volume_size" {
#  description = "size of the ebs volume attached to the opensearch instance"
#  type        = number
#  default     = 200
#}

#variable "opensearch_instance_count" {
##  description = "the number of data nodes to provision for each instance in the cluster"
#  type        = number
#  default     = 1
#}

#variable "opensearch_instance_type" {
#  description = "type of instance to be used to create the elasticsearch cluster"
#  type        = string
#  default     = "t3.medium.elasticsearch"
#}

#variable "opensearch_version" {
#  type        = string
#  description = "specify es version"
#  default     = "OpenSearch_1.1"
#}

# S3
variable "aws_account_id" {
  type = map(string)
  description = "aws account to allow for alb s3 logging"
  default = {
    us-east-1 = "127311923021"
  }
}

# S3 extra for submission
#variable "control_object_ownership" {
#  type = bool
#}

#variable "eventbridge" {
#  type = bool
#}

#variable "object_ownership" {
#  type = string
#}

variable "s3_tags" {
  type = map(string)
}

variable "s3_versioning_status" {
  description = "Set the status of the bucket versioning feature. Options include Enabled and Disabled"
  type = string 
  default = "Enabled"
}

#variable "bucketname" {
#  type = map(object({
#    name  = string
#    versioning  = string
##    eventbridge = bool
#  }))
#}
# Secrets
#variable "secret_values" {
#  type = map(object({
#    secretKey   = string
#    secretValue = map(string)
#    description = string
#  }))
#}

# Security Group
variable "allowed_ip_blocks" {
  description = "allowed ip block for the opensearch"
  type        = list(string)
  default     = []
}

variable "bastion_host_security_group_id" {
  description = "security group id of the bastion host"
  type        = string
  default     = "sg-0c94322085acbfd97"
}

variable "katalon_security_group_id" {
  description = "security group id of the bastion host"
  type        = string
  default     = "sg-0f07eae0a9b3a0bb8"
}

variable "central_ecr_account_id" {
  type  = string
  default = "986019062625"
}

variable "use_custom_trust_policy" {
  type = bool
  description = "use custom role trust policy"
  default = true
}
# SQS
variable "sqs_queues" {
  type = map(object({
    queue  = string
    dead_letter_queue_name = string
  }))
}

variable "sqs_tags" {
  type = map(string)
}

#extra ecs for validation
variable "aws_region" {
  type    = string
  default = "us-east-1"
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

variable "ecs_launch_type" {
  description = "ecs launch type - FARGATE or EC2"
  type        = string
  default     = "FARGATE"
}

variable "ecs_scheduling_strategy_extra" {
  description = "ecs scheduling strategy"
  type        = string
  default     = "REPLICA"
}

variable "role_arn_autoscaling" {
  type        = string
}

variable "extratask" {
  type = map(object({
    name      = string
    image_url = string
    cpu       = number
    memory    = number
    number_container_replicas  = number
    scheduled_max_capacity     = number
    scheduled_min_capacity     = number
  }))
}


variable "policy" {
  type = map(object({
    name      = string
    lower1    = number
    upper1    = number
    scale1    = number
    lower2    = number
    scale2    = number
  }))
}

variable "ecs_extra_tags" {
  type = map(string)
}
