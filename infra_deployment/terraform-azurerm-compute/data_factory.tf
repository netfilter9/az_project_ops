#
# Data factory
#
# This module provides very basic data factory configuration.
#
# At present, we only support a very simple approach that deplys data factory resource(s) with a default feature set
#

locals {
  data_factories = {
    for k, v in try(var.deployment.data_factories, {}) : k => merge(
      {
        # overrideable defaults
        resource_group_name = local.default_resource_group.name
        location            = local.default_resource_group.location
      },
      v,
      {
        # fixed values and internal references
        tags = merge(local.tags, try(v.tags, {}))
      }
    )
  }
}

resource "azurerm_data_factory" "data_factory" {
  for_each = {
    for k, v in local.data_factories : k => v
  }

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  tags                = each.value.tags
}