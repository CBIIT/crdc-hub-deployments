#create the quicksight-iam-role
resource "aws_iam_role" "quicksight-iam-role" {
#  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.quicksight_assume_role_policy.json
  name = "power-user-quicksight-iam-role"
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#create iam policy for the quicksight iam-role
resource "aws_iam_policy" "quicksight-policy" {
  name = "power-user-quicksight-policy"
  policy = data.aws_iam_policy_document.quicksight_pass_role_policy.json
} 

#attach policies to the quicksight iam role
resource "aws_iam_role_policy_attachment" "quicksight_attach" {
#  name       = "power-user-${terraform.workspace}-datasync-attachment"
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = aws_iam_policy.quicksight-policy.arn
}

#attach the AmazonAthenaFullAccess policy
resource "aws_iam_role_policy_attachment" "quicksight_athena_full_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

#attach the AmazonS3ReadOnlyAccess policy
resource "aws_iam_role_policy_attachment" "quicksight_s3_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#attach AWSQuicksightAthenaAccess policy
resource "aws_iam_role_policy_attachment" "quicksight_athena_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
}

#attach AWSQuickSightElasticsearchPolicy
resource "aws_iam_role_policy_attachment" "quicksight_elasticsearch_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightElasticsearchPolicy"
}

#attach AWSQuickSightSageMakerPolicy
resource "aws_iam_role_policy_attachment" "quicksight_sagemaker_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightSageMakerPolicy"
}

#attach AWSQuickSightIoTAnalyticsAccess
resource "aws_iam_role_policy_attachment" "quicksight_analytics_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSQuickSightIoTAnalyticsAccess"
}

#attach AWSQuickSightTimestreamPolicy
resource "aws_iam_role_policy_attachment" "quicksight_stream_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightTimestreamPolicy"
}

#attach QuickSightAccessForS3StorageManagementAnalyticsReadOnly
resource "aws_iam_role_policy_attachment" "quicksight_s3_mgmt_attach" {
  role = aws_iam_role.quicksight-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/QuickSightAccessForS3StorageManagementAnalyticsReadOnly"
}

#attach AWSQuickSightLambdaPolicy

