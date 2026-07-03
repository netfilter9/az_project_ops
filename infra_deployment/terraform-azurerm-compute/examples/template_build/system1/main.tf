# Terraform backend configuration for remote state file
# update key for your specific deployment
terraform {
  backend "azurerm" {
    key                  = "examples/system1"
    resource_group_name  = "tf-rg-demo"
    storage_account_name = "tfsacbdemo"
    container_name       = "tf-container-demo"
  }
}

# defintion of the Azure provider version
provider "azurerm" {
  features {}
}

variable "scenario_number" {
  description = "input variables used to control deployment"
}

variable "topology" {
  description = "input variables used to control deployment"
}

# read in template and replace placeholders with desired values
locals {
  data = jsondecode(
    templatefile(
      "${path.module}/../templates/${var.topology}.template",
      {
        scenario_number = var.scenario_number
      }
    )
  )
}

module "deployment" {
  #source = "git::ssh://git@innersource.accenture.com/iasc/terraform-azurerm-iaas_deployment.git?ref=vN.N.N"
  source = "../../../"


  deployment = local.data.deployment
  foundation = local.data.foundation

  providers = {
    azurerm.diagnostics = azurerm
  }
}