# create an IAM role for eventbridge
resource "aws_iam_role" "eventbridge-role" {
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_role_sns_policy.json
  name = "power-user-eventbridge-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#create iam policy for the eventbridge iam-role
resource "aws_iam_policy" "eventbridge-policy" {
  name = "power-user-eventbridge-policy"
  policy = data.aws_iam_policy_document.eventbridge_to_sns_policy.json
}

#attach policies to the datasync iam role
resource "aws_iam_role_policy_attachment" "eventbridge_attach" {
#  name       = "power-user-${terraform.workspace}-datasync-attachment"
  role = aws_iam_role.eventbridge-role.name
  policy_arn = aws_iam_policy.eventbridge-policy.arn
}

# create an IAM role for lambda function to publish updates about the datasync task execution status
resource "aws_iam_role" "lambda-role" {
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.assume_lambda_role_policy.json
  name = "power-user-lambda-datasync-notification-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#create iam policy for the lambda role
resource "aws_iam_policy" "lambda-policy" {
  name = "power-user-lambda-datasync-notification-policy"
  policy = data.aws_iam_policy_document.lambda_to_datasync_policy.json
}

#attach policies to the lambda role
resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}
