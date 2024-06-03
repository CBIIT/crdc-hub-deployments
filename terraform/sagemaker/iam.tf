resource "aws_iam_role" "sagemaker_instance_notebook_role" {
  name                 = local.sagemaker_instance_notebook_role_name
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.sagemaker_instance_nb_policy.json
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

resource "aws_iam_policy" "sagemaker_instance_execution_role_policy" {
  name   = local.sagemaker_instance_execution_policy_name
  policy = data.aws_iam_policy_document.sagemaker_execution_role_policy_doc.json
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "sagemaker_instance_execution_role_attachment" {
  role       = aws_iam_role.sagemaker_instance_notebook_role.name
  policy_arn = aws_iam_policy.sagemaker_instance_execution_role_policy.arn
}

# attach AWS default policy to the role
resource "aws_iam_role_policy_attachment" "sagemaker_instance_full_access" {
  role       = aws_iam_role.sagemaker_instance_notebook_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
