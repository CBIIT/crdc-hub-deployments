locals {
  level                           = terraform.workspace == "stage" || terraform.workspace == "prod" ? "prod" : "nonprod"
  trusted_role_arn = "arn:aws:iam::${var.source-account}:role/power-user-${terraform.workspace}-datasync-iam-role"
#  integration_server_profile_name = "${var.iam_prefix}-integration-server-profile"
#  permissions_boundary            = terraform.workspace == "dev" || terraform.workspace == "qa" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser" : null
#  resource_prefix = "${var.project}-${var.tier}"
  
# iam role for extra s3 to be accessible from ECS
  task_exec_role_arn = "arn:aws:iam::${var.source-account}:role/power-user-${var.project}-${terraform.workspace}-ecs-task-execution-role"
  task_role_arn = "arn:aws:iam::${var.source-account}:role/power-user-${var.project}-${terraform.workspace}-ecs-task-role"
#  env = regex("^(.*?)(2+)?$", terraform.workspace) != null ? regex("^(.*?)(2+)?$", terraform.workspace)[0] : terraform.workspace
  env = terraform.workspace
#  submission_bucket_arn = "arn:aws:s3:::crdc-hub-${local.env}-submission"
#  permission_boundary_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
}
