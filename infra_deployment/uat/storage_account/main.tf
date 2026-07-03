# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
    backend "azurerm" {
    key                  = "acc-sapk-dev-weu-sap-sta.tfstate"
    resource_group_name  = "rg-vcsi-sse-weu-mgmt-001"
    storage_account_name = "stvcsisseweutfstates001"
    container_name       = "tfstate"
    use_msi              = "true"
  }
}

# defintion of the Azure provider version
provider "azurerm" {
  features {}
}

variable "foundation" {}

module "foundation" {
  # Choose the module source: options listed in order of recommended preference
  #source = "git::ssh://git@innersource.accenture.com/iasc/terraform-azurerm-foundation.git?ref=vN.N.N"
  
  source = "../../terraform-azurerm-foundation"

  foundation = var.foundation

  providers = {
    azurerm.remote = azurerm
  }
}

output "devstorage" {
  value = module.foundation
}
