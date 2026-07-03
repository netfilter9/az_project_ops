#
# Application Security Groups
#
# WARNING: The requirement for this functionaly requires a design review
# It may belong in the iaas_deployment module along with 
# other application components rather than the foundation
#
# This file contains all the resource definitions required to create
# application security groups
#
# Logic overview:
# * Create a list of application security groups to create
# * Create required application security groups

# create a list of application security groups to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  application_security_groups = {
    for k, v in try(var.deployment.application_security_groups, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        lookup              = false
      },
      v,
      {
        # internal standards and fixed values
      }
    )
  }
}

# create application security groups
resource "azurerm_application_security_group" "application_security_groups" {
  for_each = {
    for k, v in local.application_security_groups : k => v if !v.lookup
  }

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  depends_on = [
    azurerm_resource_group.resource_group
  ]
}

data "azurerm_application_security_group" "application_security_groups" {
  for_each = {
    for k, v in local.application_security_groups : k => v if v.lookup
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_application_security_group.application_security_groups]
}

locals {
  all_application_security_groups = merge(
    azurerm_application_security_group.application_security_groups,
    data.azurerm_application_security_group.application_security_groups
  )
}

/*
*/