terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      EnvironmentTier = terraform.workspace
      CreatedBy       = "Tracy Truong"
      ResourceName    = "NCI-crdc-hub-${terraform.workspace}"
      ManagedBy       = "terraform"
      Project         = "crdc dh"
      Backup          = local.level
      PatchGroup      = local.level
      ApplicationName = "CRDC Hub"
    }
  }
}
