#
# Network Watcher
#
# This file contains all the resource definitions that you need to 
# provision Network Watcher
#
#

locals {
  network_watchers = {
    for k, v in try(var.foundation.network_watchers, {}) : k => merge(
      {
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        lookup              = false
      },
      v,
      {
      }
    )
  }
}

#can only have one per region per subscription
#Create Network Watcher
resource "azurerm_network_watcher" "network_watcher" {
  for_each = {
    for k, v in local.network_watchers : k => v if !v.lookup
  }

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
}

#Lookup existing network watcher
data "azurerm_network_watcher" "network_watcher" {
  for_each = {
    for k, v in local.network_watchers : k => v if v.lookup
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name

  # required as this can be a lookup for an existing network watcher
  depends_on = [azurerm_network_watcher.network_watcher]
}

locals {
  all_network_watchers = merge(
    azurerm_network_watcher.network_watcher,
    data.azurerm_network_watcher.network_watcher
  )
}

/*
*/