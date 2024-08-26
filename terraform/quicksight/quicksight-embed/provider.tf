terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      EnvironmentTier = terraform.workspace
      CreatedBy       = "Tracy Truong"
      ResourceName    = "NCI-crdc-data-management-${terraform.workspace}"
      ManagedBy       = "terraform"
      Project         = "crdc data management"
      Backup          = local.level
      PatchGroup      = local.level
      ApplicationName = "CRDC Data Management"
    }
  }
}
