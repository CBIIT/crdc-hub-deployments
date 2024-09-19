locals {
  level                           = terraform.workspace == "stage" || terraform.workspace == "prod" ? "prod" : "nonprod"
#  permissions_boundary            = terraform.workspace == "dev" || terraform.workspace == "qa" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser" : null
#  resource_prefix = "${var.project}-${var.tier}"
#  env = regex("^(.*?)(2+)?$", terraform.workspace) != null ? regex("^(.*?)(2+)?$", terraform.workspace)[0] : terraform.workspace
  env = terraform.workspace
  permission_boundary_arn  = terraform.workspace == "stage" || terraform.workspace == "prod" ? null : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
}
