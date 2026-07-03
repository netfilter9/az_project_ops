#
# Lookups
#
# Lookups for external resource references that don't have a more appropriate
# tf file
#

# lookup the main virtual network
data "azurerm_virtual_network" "lookups" {
  name                = local.foundation.network.name
  resource_group_name = local.foundation.network.resource_group_name
}

# look up all required subnets by checking across server groups
data "azurerm_subnet" "lookups" {
  for_each = toset(data.azurerm_virtual_network.lookups.subnets)

  name                 = each.key
  virtual_network_name = local.foundation.network.name
  resource_group_name  = local.foundation.network.resource_group_name
}

# lookup backup policies
# default is to assume no backup required if policy reference isn't provided
data "azurerm_backup_policy_vm" "lookups" {
  for_each = toset([
    for group in try(var.deployment.server_groups, {}) :
    group.backup_policy if merge({ backup_policy = null }, group).backup_policy != null
  ])

  name                = each.key
  resource_group_name = local.foundation.recovery_vault.resource_group_name
  recovery_vault_name = local.foundation.recovery_vault.name
}

/*
*/
