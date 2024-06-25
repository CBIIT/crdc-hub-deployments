resource "aws_iam_role" "sagemaker_instance_notebook_role" {
  name                 = local.sagemaker_instance_notebook_role_name
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.sagemaker_instance_nb_policy.json
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

# policy for instance notebook
resource "aws_iam_policy" "sagemaker_instance_execution_role_policy" {
  name   = local.sagemaker_instance_execution_policy_name
  policy = data.aws_iam_policy_document.sagemaker_execution_role_policy_doc.json
}

# attach instance notebook policy to role sagemaker instance notebook
resource "aws_iam_role_policy_attachment" "sagemaker_instance_execution_role_attachment" {
  role       = aws_iam_role.sagemaker_instance_notebook_role.name
  policy_arn = aws_iam_policy.sagemaker_instance_execution_role_policy.arn
}

# attach AWS default policy to the role sagemaker instance notebook
resource "aws_iam_role_policy_attachment" "sagemaker_instance_full_access" {
  role       = aws_iam_role.sagemaker_instance_notebook_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# policy for the sagemaker admin role
resource "aws_iam_policy" "sagemaker_instance_admin_role_policy" {
  name   = local.sagemaker_instance_admin_role_policy_name
   policy = data.aws_iam_policy_document.sagemaker_permission_admin_role_policy_doc.json
}

# Attach sagemake permission admin role policy
resource "aws_iam_role_policy_attachment" "sagemaker_instance_admin_role_attachment" {
  role       = aws_iam_role.sagemaker_instance_notebook_role.name
  policy_arn = aws_iam_policy.sagemaker_instance_admin_role_policy.arn
}

# create canvas bedrock role
resource "aws_iam_role" "sagemaker_canvas_bedrock_role" {
  name                 = local.sagemaker_canvas_bedrock_role_name
  assume_role_policy   = var.use_custom_trust_policy ? var.custom_trust_policy: data.aws_iam_policy_document.sagemaker_instance_nb_policy.json
  permissions_boundary = var.target_account_cloudone ? local.permission_boundary_arn : null
}

#policy for canvas bedrock role
resource "aws_iam_policy" "sagemaker_canvas_bedrock_role_policy" {
  name   = local.sagemaker_canvas_execution_policy_name
  policy = data.aws_iam_policy_document.sagemaker_execution_role_policy_doc.json
}
# attach AWS default policy to the canvas bedrock role
resource "aws_iam_role_policy_attachment" "sagemaker_canvas_bedrock_access" {
  role       = aws_iam_role.sagemaker_canvas_bedrock_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerCanvasBedrockAccess"
}

