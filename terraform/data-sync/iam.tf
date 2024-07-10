#create the datasync-iam-role
resource "aws_iam_role" "datasync-iam-role" {
#  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_policy.json
  name = "power-user-${terraform.workspace}-datasync-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#create iam policy for the datasync iam-role
resource "aws_iam_policy" "datasync-policy" {
  name = "power-user-${terraform.workspace}-datasync-policy"
  policy = data.aws_iam_policy_document.datasync-policy.json
} 

#attach policies to the datasync iam role
resource "aws_iam_role_policy_attachment" "datasync" {
#  name       = "power-user-${terraform.workspace}-datasync-attachment"
  role = aws_iam_role.datasync-iam-role.name
  policy_arn = aws_iam_policy.datasync-policy.arn
}

# create the 2nd role to access s3 in the destination acct
resource "aws_iam_role" "datasync-s3-access-role" {
#  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_policy.json
  name = "power-user-${terraform.workspace}-datasync-s3-access-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

# create policy for datasync s3
resource "aws_iam_policy" "datasync-s3-policy" {
  name = "power-user-${terraform.workspace}-datasync-s3-policy"
  policy = data.aws_iam_policy_document.datasync-s3-access.json
}

#attach policies to the 2nd role to access s3 in the destination acct
resource "aws_iam_role_policy_attachment" "s3-access" {
#  name       = "power-user-${terraform.workspace}-s3-access-attachment"
  role = aws_iam_role.datasync-s3-access-role.name
  policy_arn = aws_iam_policy.datasync-s3-policy.arn
}

# attach datasync & s3 access to the task and execute role
resource "aws_iam_role_policy_attachment" "datasync-task-access" {
  roles = [data.aws_iam_role.datasync_task_role.name,data.aws_iam_role.datasync_task_execution_role.name]
  policy_arn = aws_iam_policy.datasync-policy.arn
}

resource "aws_iam_role_policy_attachment" "s3-task-access" {
  roles = [data.aws_iam_role.datasync_task_role.name,data.aws_iam_role.datasync_task_execution_role.name]
  policy_arn = aws_iam_policy.datasync-s3-policy.arn
}
