terraform {
  required_version = ">=1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "wa-terraform-1"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "wa-terraform-state"
    encrypt        = false
  }
}
