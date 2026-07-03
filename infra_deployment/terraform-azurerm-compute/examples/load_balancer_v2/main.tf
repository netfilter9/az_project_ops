# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
  backend "azurerm" {
    key                  = "examples/custom_build"
    resource_group_name  = "tf-rg-demo"
    storage_account_name = "tfsacbdemo"
    container_name       = "tf-container-demo"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.78.0"
    }
  }
}

# defintion of the Azure provider version
provider "azurerm" {
  features {}
}

#define inputs
variable "deployment" {
  description = "definition for the deployment"
}
variable "foundation" {
  description = "shared foundation variables such as vnet reference"
}
variable "secrets" {
  description = "a map of secrets"
  sensitive   = true
}

# call to custom terraform module
module "deployment" {
  # module source (use tagged version controlled reference for preference)
  #source = "git::ssh://git@innersource.accenture.com/iasc/terraform-azurerm-iaas_deployment.git?ref=vN.N.N"
  source = "../../"

  # module input variables
  deployment = var.deployment
  foundation = var.foundation
  secrets    = var.secrets

  # if diagnostics is in a shared subscription, pass in a secondary provider.
  providers = {
    azurerm.diagnostics = azurerm
  }
}