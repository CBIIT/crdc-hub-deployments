# global variables
variable "datasync-destination-bucket-names" {
  description = "destination bucket  name"
  type = list(string)
}
#variable "datasync-source-bucket-name" {
#  description = "source bucket name"
#  type = string
#}


variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default     = true
}

variable "resource_prefix" {
  description = "the prefix to add when creating resources"
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


variable "project" {
  description = "name of the project"
  type        = string
}

#variable "tier" {
#  type = string
#}
variable "datasync_tags" {
  type        = map(string)
}

variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}


variable "s3_tags" {
  type = map(string)
}

variable "source-account" {
  type = string
}


#variable "iam_prefix" {
#  type        = string
#  default     = "power-user"
#  description = "nci iam power user prefix"
#}

#variable "s3_force_destroy" {
#  description = "force destroy bucket"
#  default     = true
#  type        = bool
#}

#variable "create_files_bucket" {
#  description = "indicate if you want to create files bucket or use existing one"
#  type        = bool
#  default     = false
#}


# Instance Profile
#variable "create_instance_profile" {
#  type        = bool
#  default     = false
#  description = "set to create instance profile"
#}


# S3
#variable "aws_account_id" {
#  type = map(string)
#  description = "aws account to allow for alb s3 logging"
#  default = {
#    us-east-1 = "127311923021"
#  }
#}

# S3 extra for submission
#variable "control_object_ownership" {
#  type = bool
#}

#variable "eventbridge" {
#  type = bool
#}

#variable "object_ownership" {
#  type = string
#}

#variable "s3_versioning_status" {
#  description = "Set the status of the bucket versioning feature. Options include Enabled and Disabled"
#  type = string 
#  default = "Enabled"
#}

#variable "bucketname" {
#  type = map(object({
#    name  = string
#    versioning  = string
##    eventbridge = bool
