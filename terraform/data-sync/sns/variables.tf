#var for sns
variable "datasync_status_topic" {
  type = string
}

variable "emails" {
  type = list(string)
}

#variable "datasync_status_rule" {
#  type = string
#}

variable "lambda_datasync_status_rule" {
  type = string
}
#variable "project" {
#  description = "name of the project"
#  type        = string
#}


variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}

variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default     = true
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
