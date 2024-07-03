locals {
  sagemaker_instance_notebook_role_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-role" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-role"
  sagemaker_studio_role_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-studio-execute-role" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-studio-execute-role"
  #sagemaker_instance_notebook_role_name = var.target_account_cloudone ? "${var.iam_prefix}-sagemaker-instance-role" : "sagemaker-instance-role"
  sagemaker_instance_execution_policy_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-role-policy" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-role-policy"
  sagemaker_instance_admin_role_policy_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-admin-role-policy" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-instance-admin-role-policy"
  sagemaker_canvas_bedrock_role_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-canvas-bedrock-role" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-canvas-bedrock-role"
  sagemaker_canvas_execution_policy_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-${terraform.workspace}-sagemaker-canvas-bedrock-role-policy" : "${var.resource_prefix}-${terraform.workspace}-sagemaker-canvas-bedrock-role-policy"
  permission_boundary_arn         = terraform.workspace == "stage" || terraform.workspace == "prod" ? null : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionBoundary_PowerUser"
}
