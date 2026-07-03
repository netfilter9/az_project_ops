#
# Availability sets
#
# This module allows one more more availability sets to be created
# New availability sets default to 2 update domains and 2 fault domains but this can be overidden
# it is also possible to optionally associate the AS with a PPG
#

# create a list of availability sets to create by combining
# defaults, inputs, fixed values and internal references 

locals {
  availability_sets = {
    for k, v in try(var.deployment.availability_sets, {}) : k => merge(
      {
        # overrideable defaults
        lookup_id                    = null
        platform_update_domain_count = 2
        platform_fault_domain_count  = 2
        resource_group_name          = local.default_resource_group.name
        location                     = local.default_resource_group.location
      },
      v,
      {
        # fixed values and internal references
        proximity_placement_group_id = try(v.ppg_id, azurerm_proximity_placement_group.proximity_placement_groups[v.ppg_name].id, null)
        tags = merge(
          local.tags,
          try(v.tags, {})
        )
      }
    )
  }
}

# create availability sets if required
resource "azurerm_availability_set" "availability_sets" {
  for_each = {
    for k, v in local.availability_sets : k => v if v.lookup_id == null
  }

  name                         = each.key
  resource_group_name          = local.all_resource_groups[each.value.resource_group_name].name
  location                     = each.value.location
  platform_update_domain_count = each.value.platform_update_domain_count
  platform_fault_domain_count  = each.value.platform_fault_domain_count
  proximity_placement_group_id = each.value.proximity_placement_group_id
  tags                         = each.value.tags
  managed                      = true
}
/*
*/