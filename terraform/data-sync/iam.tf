#create the datasync-iam-role
resource "aws_iam_role" "datasync-iam-role" {
#  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_policy.json
  name = "power-user-${terraform.workspace}-datasync-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}
