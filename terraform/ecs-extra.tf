module "ecs-extra" {
  source                    = "~/crdc-hub-deployments/terraform/modules/ecs-extra"
  project                = var.project
  aws_region                = var.aws_region
  tier                      = var.tier
  ecs_network_mode          = var.ecs_network_mode
  security_group_ids        = var.security_group_ids
  tags                      = var.tags
  subnet_ids                = var.subnet_ids
  ecs_launch_type           = var.ecs_launch_type
  ecs_scheduling_strategy_extra  = var.ecs_scheduling_strategy_extra
  extratask                 = var.extratask
  policy                    = var.policy
}
