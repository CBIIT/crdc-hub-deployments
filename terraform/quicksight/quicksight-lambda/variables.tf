# global variables
variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default     = true
}

#variable "resource_prefix" {
#  description = "the prefix to add when creating resources"
#  type        = string
#}

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


variable "project" {
  description = "name of the project"
  type        = string
}

#variable "tier" {
#  type = string
#}

variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}


variable "lambda-funtions" {
  type = list(string)
}

variable "mongodb_catalog_name" {
  type = list(string)
}
