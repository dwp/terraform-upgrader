locals {

  # Configured as per Tagging doc requirements https://engineering.dwp.gov.uk/policies/hcs-cloud-hosting-policies/resource-identification-tagging/
  # Also required as per Tenable documentation https://engineering.dwp.gov.uk/products/gold-images/agents/tenable/
  hcs_environment = {
    development    = "Dev"
    qa             = "Test"
    integration    = "Test"
    preprod        = "Stage"
    production     = "Production"
    management     = "SP_Tooling"
    management-dev = "DT_Tooling"
  } 
}