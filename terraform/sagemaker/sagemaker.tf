# create sagemaker instance notebook
#resource "aws_sagemaker_notebook_instance" "sagemaker-notebook" {
#  name                  = var.sagemaker_notebook
#  instance_type         = "ml.t2.medium"
#  role_arn              = aws_iam_role.sagemaker_instance_notebook_role.arn
#  subnet_id             = var.subnet_id
#  security_group_ids    = var.security_group_ids
  
#  tags = {
#    Name = var.sagemaker_notebook
#  }
#}

# Create SageMaker Studio Domain
resource "aws_sagemaker_domain" "sagemaker_studio_domain" {
  domain_name = "nci-crdc-datahub-sagemaker-studio-domain-${terraform.workspace}"
  auth_mode   = "IAM"
  default_user_settings {
    execution_role = aws_iam_role.sagemaker_studio_role.arn
    canvas_app_settings {
      time_series_forecasting_settings {
        status = "DISABLED"
      }
    }
  }
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_id
  app_network_access_type = var.network_access_type

  default_space_settings {
    execution_role = aws_iam_role.sagemaker_studio_role.arn
  }
}

#create sagemaker user profile
#resource "aws_sagemaker_user_profile" "sagemaker_user_profile" {
#  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain.id
#  user_profile_name = var.profile_name
#  user_settings {
#    execution_role  = aws_iam_role.sagemaker_studio_role.arn
#    canvas_app_settings {
#      time_series_forecasting_settings {
#        status = "DISABLED"
#      }
#    }
##    studio_web_portal = "ENABLED"
  #  security_groups = [module.sagemaker_domain_vpc.security_group_id]
#  }
#}


# create multiple users profiles
resource "aws_sagemaker_user_profile" "sagemaker_user_profile" {
  for_each = var.users
  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain.id
  user_profile_name = each.value.profile_name
  user_settings {
    execution_role  = aws_iam_role.sagemaker_studio_role[each.key].arn
    canvas_app_settings {
      time_series_forecasting_settings {
        status = "DISABLED"
      }
    }
  }
  
}
