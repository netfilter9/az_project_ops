# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
    backend "azurerm" {
    key                  = "acc-sapk-ppd-weu-rg.tfstate"
    resource_group_name  = "rg-vcsi-sse-weu-mgmt-001"
    storage_account_name = "stvcsisseweutfstates001"
    container_name       = "tfstate"
    use_msi              = true
  }
}

# defintion of the Azure provider version
provider "azurerm" {
  features {}
}

#define inputs
variable "deployment" {}
variable "foundation" { default = null }

# call to custom terraform module
module "deployment" {
  # module source (use tagged version controlled reference for preference)
  
  source = "../../terraform-azurerm-compute/"

  # module input variables
  deployment     = var.deployment
  foundation     = var.foundation # != null ? var.foundation : jsondecode(file("${path.module}/../../global_config/foundation.tfvars.json")).foundation

  # if diagnostics is in a shared subscription, pass in a secondary provider.
  providers = {
    azurerm.diagnostics = azurerm
  }
}
