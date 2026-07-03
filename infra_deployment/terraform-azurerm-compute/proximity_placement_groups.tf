#
# Proximity placement groups
#
# This module supports the creation of new  proximity placement groups
#

# create a list of ppgs to create by combining
# defaults, inputs, fixed values and internal references
locals {
  proximity_placement_groups = {
    for k, v in try(var.deployment.proximity_placement_groups, {}) : k => merge(
      {
        # overrideable defaults
        resource_group_name = local.default_resource_group.name
        location            = try(v.location, local.default_resource_group.location)
        zone                = null
        allowed_vm_sizes    = null
      },
      v,
      {
        # fixed values and internal references
        tags = merge(
          local.tags,
          try(v.tags, {})
        )
      }
    )
  }
}

# create proximity placement groups if required
resource "azurerm_proximity_placement_group" "proximity_placement_groups" {
  for_each = {
    for k, v in local.proximity_placement_groups : k => v
  }

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  tags                = each.value.tags
  zone                = each.value.zone
  allowed_vm_sizes    = each.value.allowed_vm_sizes
}
# Lookup ppg
data "azurerm_proximity_placement_group" "proximity_placement_groups" {
   for_each = {
    for k, v in local.proximity_placement_groups : k => v
  }
 
  name  = each.key
  resource_group_name = each.value.resource_group_name
  depends_on = [azurerm_proximity_placement_group.proximity_placement_groups]
}
/*
*/