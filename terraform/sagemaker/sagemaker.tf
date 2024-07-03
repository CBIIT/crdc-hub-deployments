resource "aws_sagemaker_notebook_instance" "sagemaker-notebook" {
  name                  = var.sagemaker_notebook
  instance_type         = "ml.t2.medium"
  role_arn              = aws_iam_role.sagemaker_instance_notebook_role.arn
#  subnet_id             = var.subnet_id
#  security_group_ids    = var.security_group_ids
  
  tags = {
    Name = var.sagemaker_notebook
  }
}

# Create SageMaker Studio Domain
resource "aws_sagemaker_domain" "sagemaker_studio_domain" {
  domain_name = "nci-crdc-datahub-sagemaker-studio-domain-${terraform.workspace}"
  auth_mode   = "IAM"
  default_user_settings {
    execution_role = aws_iam_role.sagemaker_studio_role.arn
  }
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_id

  default_space_settings {
    execution_role = aws_iam_role.sagemaker_studio_role.arn
  }
  #canvas app settings
#  time_series_forecasting_settings {
#    status = "DISABLED"
#  }
}
