locals {
  level                           = terraform.workspace == "stage" || terraform.workspace == "prod" ? "prod" : "nonprod"
#  integration_server_profile_name = "${var.iam_prefix}-integration-server-profile"
#  permissions_boundary            = terraform.workspace == "dev" || terraform.workspace == "qa" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser" : null
#  resource_prefix = "${var.project}-${var.tier}"
#  env = regex("^(.*?)(2+)?$", terraform.workspace) != null ? regex("^(.*?)(2+)?$", terraform.workspace)[0] : terraform.workspace
  env = terraform.workspace
  permission_boundary_arn  = terraform.workspace == "stage" || terraform.workspace == "prod" ? null : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
  source_bucket_arn = "arn:aws:s3:::${var.datasync-source-bucket-name}"
#  destination_bucket_arn = "arn:aws:s3:::${var.datasync-destination-bucket-name}"
  datasync_task_role_name = "power-user-${var.project}-${terraform.workspace}-ecs-task-role"
  datasync_task_execution_role_name = "power-user-${var.project}-${terraform.workspace}-ecs-task-execution-role"
}
