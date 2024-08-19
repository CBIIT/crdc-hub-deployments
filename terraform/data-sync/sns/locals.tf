locals {
  level                           = terraform.workspace == "stage" || terraform.workspace == "prod" ? "prod" : "nonprod"
  env = terraform.workspace
}
