# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
  
}

# defintion of the Azure provider version
provider "azurerm" {
  features {}
}

variable "foundation" {}

module "foundation" {
  # Choose the module source: options listed in order of recommended preference
  
  source = "../terraform-azurerm-foundation/"

  foundation = var.foundation

  providers = {
    azurerm.remote = azurerm
  }
}

output "test" {
  value = module.foundation
}