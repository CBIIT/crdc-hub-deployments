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

# create policy for datasync s3
resource "aws_iam_policy" "datasync-s3-policy" {
  name = "power-user-${terraform.workspace}-datasync-s3-policy"
  policy = data.aws_iam_policy_document.datasync-s3-access.json
}

#attach policies to the datasync iam role
resource "aws_iam_policy_attachment" "datasync" {
  name       = "power-user-${terraform.workspace}-datasync-attachment"
  policy_arn = aws_iam_policy.datasync-policy.arn
}

resource "aws_iam_policy_attachment" "s3-access" {
  name       = "power-user-${terraform.workspace}-s3-access-attachment"
  policy_arn = aws_iam_policy.datasync-s3-policy.arn
}
