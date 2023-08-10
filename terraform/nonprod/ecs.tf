module "ecs" {
  source                    = "git::https://github.com/CBIIT/datacommons-devops.git//terraform/modules/ecs?ref=central-ecr"
  resource_prefix           = local.resource_prefix
  stack_name                = var.project
  tags                      = var.tags
  vpc_id                    = var.vpc_id
  ecs_subnet_ids            = var.private_subnet_ids
  application_url           = local.application_url
  env                       = terraform.workspace
  microservices             = var.microservices
  alb_https_listener_arn    = module.alb.alb_https_listener_arn
  target_account_cloudone   = var.target_account_cloudone
  allow_cloudwatch_stream   = var.allow_cloudwatch_stream
  use_local_account_id      = var.use_local_account_id
  central_ecr_account_id    = var.central_ecr_account_id
}
