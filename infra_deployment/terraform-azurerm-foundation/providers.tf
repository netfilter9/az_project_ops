#
# Providers
#
# This file handles the provider lookup logic used by the 
# various parts of the foundation deployment

# Proxy provider configuration block
# This ensures that a "remote" provider is defined just in case
# network peering need to be performed against a secondary subscription
#
# Where you don't require a secondary subscription you should just add
# the following to your module call:
#  providers = {
#    azurerm.remote = azurerm
#  }
terraform {
  # If thes constraint are too restrictive for you and you are willing to do the 
  # testing, just send a pull request to enable support for older versions
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.0.1, < 4.0.0"
      configuration_aliases = [azurerm.remote]
    }
  }
}

# this is required as a reference to the current subscription
# it is used by things like the key vault declaration
data "azurerm_client_config" "current" {}