# 
# Providers
#
# This file defines the minimum terraform version and azure version required for 
# use of this module
#
# This block also defines the azurerm.diagnostics alias which enables support for 
# diagnostics which are defined in a secondary subscription.
# To use a secondary subscription you will need to define another provder block:
#   providers = {
#     azurerm.diagnostics = azurerm
#     # add refs to secondary subscription
#   }
# and you will need to update the providers defined in the module call
#   provider "azurerm" {
#     alias = "diagnostics"
#   }
terraform {
  # If thes constraint are too restrictive for you and you are willing to do the 
  # testing, just send a pull request to enable support for older versions
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.0.2, < 4.0.0"
      configuration_aliases = [azurerm.diagnostics]
    }
  }
}