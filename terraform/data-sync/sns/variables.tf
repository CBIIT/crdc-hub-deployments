#var for sns
variable "datasync_status_topic" {
  type = string
}

variable "emails" {
  type = list(string)
}

variable "datasync_status_rule" {
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
