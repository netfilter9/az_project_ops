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
    for k, v in try(var.foundation.application_security_groups, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        tags                = try(var.foundation.tags, {})
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
  for_each = local.application_security_groups

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name

  tags = each.value.tags
}

locals {
  lookup_application_security_groups = distinct(
    concat(
      local.nsg_application_security_groups,
      flatten(
        [
          for k, v in try(var.foundation.application_security_groups, {}) : {
            resource_group_name             = try(v.resource_group_name, local.default_resource_group.name),
            application_security_group_name = k
          }
        ]
      )
    )
  )
}

data "azurerm_application_security_group" "application_security_groups" {
  for_each = {
    for entry in local.lookup_application_security_groups : "${entry.application_security_group_name}" => entry
  }

  name                = each.value.application_security_group_name
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_application_security_group.application_security_groups]

}

output "asgs" {
  value = data.azurerm_application_security_group.application_security_groups
}
/*
*/