resource "aws_sagemaker_notebook_instance" "sagemaker-notebook" {
  name                  = "tracy-test-notebook"
  instance_type         = "ml.t2.medium"
  role_arn              = aws_iam_role.sagemaker_instance_notebook_role.arn
#  subnet_id             = var.subnet_id
#  security_group_ids    = var.security_group_ids
  
  tags = {
    Name = "tracy-test-notebook"
  }
}
