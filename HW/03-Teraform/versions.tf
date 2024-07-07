terraform {
  required_version = ">=1.9.0"

  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "17.1.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state"
    key = "terraform.tfstate"

    region = "main"
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
}
