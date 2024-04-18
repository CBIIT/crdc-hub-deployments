locals {
  bastion_port                    = 22
  http_port                       = 80
  any_port                        = 0
  any_protocol                    = "-1"
  tcp_protocol                    = "tcp"
  https_port                      = "443"
  level                           = terraform.workspace == "stage" || terraform.workspace == "prod" ? "prod" : "nonprod"
#  neo4j_http                      = 7474
#  neo4j_https                     = 7473
#  neo4j_bolt                      = 7687
  integration_server_profile_name = "${var.iam_prefix}-integration-server-profile"
  permissions_boundary            = terraform.workspace == "dev" || terraform.workspace == "qa" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser" : null
  #nih_ip_cidrs =  terraform.workspace == "prod" || terraform.workspace == "stage" ? ["0.0.0.0/0"] : [ "129.43.0.0/16" , "137.187.0.0/16"  , "165.112.0.0/16" , "156.40.0.0/16"  , "128.231.0.0/16" , "130.14.0.0/16" , "157.98.0.0/16"]
  nih_ip_cidrs = ["0.0.0.0/0"]
  all_ips      =  local.nih_ip_cidrs
  #allowed_alb_ip_range = terraform.workspace == "prod" || terraform.workspace == "stage" ?  local.all_ips : local.nih_ip_cidrs
  allowed_alb_ip_range         = local.nih_ip_cidrs
  #fargate_security_group_ports = ["443", "3306", "7473", "7474", "7687"]
  fargate_security_group_ports = ["443"]
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
  
  #ALB
  #alb_subnet_ids      = terraform.workspace == "prod" || terraform.workspace == "stage" ? var.public_subnet_ids : var.private_subnet_ids
  alb_subnet_ids      = terraform.workspace == "prod" ? var.public_subnet_ids : var.private_subnet_ids
  alb_log_bucket_name = terraform.workspace == "prod" || terraform.workspace == "stage" ? "prod-alb-access-logs" : "nonprod-alb-access-logs"
  cert_types          = "IMPORTED"
  
  resource_prefix = "${var.project}-${var.tier}"
  
# iam role for extra s3 to be accessible from ECS
  iam_role_name = "power-user-${var.project}-${var.tier}-ecs-task-execution-role"
  task_role_name = "power-user-${var.project}-${var.tier}-ecs-task-role"
  # ECS
  application_url = terraform.workspace == "prod" ? "${var.application_subdomain}.${var.domain_name}" : "${var.application_subdomain}-${terraform.workspace}.${var.domain_name}"
  env = regex("^(.*?)(2+)?$", terraform.workspace) != null ? regex("^(.*?)(2+)?$", terraform.workspace)[0] : terraform.workspace
  submission_bucket_arn = "arn:aws:s3:::crdc-hub-${local.env}-submission"
  permission_boundary_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
}
