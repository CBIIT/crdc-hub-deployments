locals {
  sagemaker_instance_notebook_role_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-sagemaker-instance-role" : "${var.resource_prefix}-sagemaker-instance-role"
  sagemaker_instance_execution_policy_name = var.target_account_cloudone ? "${var.iam_prefix}-${var.resource_prefix}-sagemaker-instance-role-policy" : "${var.resource_prefix}-sagemaker-instance-role-policy"
}
