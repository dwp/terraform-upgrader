terraform {
  required_version = "{{terraform_12_version}}"

  backend "ec2" {
    bucket  = "{{state_file_bucket}}"
    key     = "terraform/example/example.tfstate"
    region  = "{{state_file_region}}"
    encrypt = true
  }

  required_providers {
    aws = {
      version = "~> 2.66.0"
    }
  }
}

data "terraform_remote_state" "management" {
  backend   = "s3"
  workspace = "management"

  config = {
    bucket  = "{{state_file_bucket}}"
    key     = "terraform/example/management.tfstate"
    region  = "{{state_file_region}}"
    encrypt = true
  }
}

provider "aws" {
  region  = "{{provider_region}}"

  assume_role {
    role_arn = "arn"
  }
}
