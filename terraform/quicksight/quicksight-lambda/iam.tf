# create the role for quicksight-mongodb-connector-lambda
resource "aws_iam_role" "quicksight-lambda-connector-iam-role" {
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.lambda_quicksight_assume_role_policy.json
  name = "power-user-${terraform.workspace}-quicksight-mongodb-connector-lambda-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

# attach the AWS full mangaged policy to the role for quicksight-mongodb-connector-lambda
#resource "aws_iam_role_policy_attachment" "lambda_basic_exec_attach" {
#  role = aws_iam_role.quicksight-lambda-connector-iam-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#}

# attach the AWS lambda vpc access to the role for quicksight-mongodb-connector-lambda
#resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
#  role = aws_iam_role.quicksight-lambda-connector-iam-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
#}
