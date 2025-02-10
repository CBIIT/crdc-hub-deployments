# global variables
variable "project" {
  description = "name of the project"
  type        = string
}

#variable "tier" {
#  type = string
#}
#variable "tags" {
#  description = "tags to associate with this instance"
#  type        = map(string)
#}

variable "region" {
  description = "aws region to use for this resource"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
}

variable "s3_tags" {
  type = map(string)
}

variable "source-account" {
  type = string
}

variable "datasync-destination-bucket-name" {
  type = string
}
#variable "target_account_cloudone" {
#  description = "to add check conditions on whether the resources are brought up in cloudone or not"
#  type        = bool
#  default     = true
#}

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

# Cloudfront
#variable "alarms" {
#  description = "alarms to be configured"
#  type        = map(map(string))
#}

#variable "cloudfront_distribution_bucket_name" {
#  description = "specify the name of s3 bucket for cloudfront"
#  type        = string
#}

#variable "cloudfront_log_path_prefix_key" {
#  description = "path prefix to where cloudfront send logs to s3 bucket"
#  type        = string
#  default     = "cloudfront/logs"
#}

#variable "cloudfront_origin_acess_identity_description" {
#  description = "description for OAI"
#  type        = string
#  default     = "cloudfront origin access identify for s3"
#}

#variable "cloudfront_slack_channel_name" {
#  type        = string
#  description = "cloudfront slack name"
#}

#variable "create_cloudfront" {
#  description = "create cloudfront or not"
#  type        = bool
#  default     = false
#}

#variable "create_files_bucket" {
#  description = "indicate if you want to create files bucket or use existing one"
#  type        = bool
#  default     = false
#}

#variable "slack_secret_name" {
#  type        = string
#  description = "name of cloudfront slack secret"
#}



# Instance Profile
#variable "create_instance_profile" {
#  type        = bool
#  default     = false
#  description = "set to create instance profile"
#}

#variable "create_cloudwatch_log_policy" {
#  description = "Due cloudwatch log policy limits, this should be option, we can use an existing policy"
#  default     = false
#  type        = bool
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
#  }))
#}
# Secrets
#variable "secret_values" {
#  type = map(object({
#    secretKey   = string
#    secretValue = map(string)
#    description = string
#  }))
#}
