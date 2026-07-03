# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
  backend "azurerm" {
    key                  = "examples/foundation-keyvault-test.tfstate"
    resource_group_name  = "tf-rg-demo"
    storage_account_name = "tfsacbdemo"
    container_name       = "tf-container-demo"
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
  source = "../../"

  foundation = var.foundation

  providers = {
    azurerm.remote = azurerm
  }
}

# output "test" {
#   value = module.foundation
# }