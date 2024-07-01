variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default     = true
}

#variable "resource_prefix" {
#  description = "the prefix to add when creating resources"
#  type        = string
#}

variable "iam_prefix" {
  description = "The string prefix for IAM roles and policies to conform to NCI power-user compliance"
  type        = string
  default     = "power-user"
}

variable "vpc_id" {
  description = "VPC Id to to launch the ALB"
  type        = string
}

variable "use_custom_trust_policy" {
  type = bool
  description = "use custom role trust policy"
  default = false
}

variable "custom_trust_policy" {
  type = string
  description = "custom role trust policy"
  default = null
}

variable "subnet_id" {
  type        = list(string)
}

variable security_group_ids {
  type    = list(string)
}
