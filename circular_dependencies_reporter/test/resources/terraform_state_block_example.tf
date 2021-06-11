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