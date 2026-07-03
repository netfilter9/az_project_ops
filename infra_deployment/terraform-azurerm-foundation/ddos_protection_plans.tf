#
# DDOS Protection Plan
#
# This file contains all the resources required in order to provison
# ddos_protection_plans 
#
# Logic overview: 
# * Generate a list of ddos_pretection_plans to create
# * Create them

# generate local array of plans to create and augment with defaults
locals {
  ddos_protection_plans = {
    for k, v in try(var.foundation.ddos_protection_plans, {}) : k => merge(
      {
        # defaults which can be overridden
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        lookup              = false
      },
      v,
      {
        # fixed values as required
      }
    )
  }
}

# create plans where not "lookup"
resource "azurerm_network_ddos_protection_plan" "ddos_protection_plans" {
  for_each = {
    for k, v in local.ddos_protection_plans : k => v if !v.lookup
  }

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
}

# look up all plans
data "azurerm_network_ddos_protection_plan" "ddos_protection_plans" {
  for_each = {
    for k, v in local.ddos_protection_plans : k => v if v.lookup
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name

  # don't lookup until new plans created.
  depends_on = [
    azurerm_network_ddos_protection_plan.ddos_protection_plans
  ]
}

locals {
  all_ddos_protection_plans = merge(
    azurerm_network_ddos_protection_plan.ddos_protection_plans,
    data.azurerm_network_ddos_protection_plan.ddos_protection_plans
  )
}