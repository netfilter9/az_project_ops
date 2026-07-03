#
# Site Recovery
#
# This file contains definitions for the creation of ASR vaults and
# other associated components
# 
#
#

# defaults, inputs, fixed values and internal references  
locals {
  asr_vaults = {
    for k, v in try(var.foundation.recovery_vaults, {}) : k => merge(
      {
        # overrideable defaults     
        target_location     = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        policy = {
          name                                                 = null
          recovery_point_retention_in_minutes                  = null
          application_consistent_snapshot_frequency_in_minutes = null
        }
      },
      v,
      {
        # fixed values and internal references
        sku                 = "Standard"
        soft_delete_enabled = false
      }
    ) if try(v.is_asr, false) == true
  }
}

# create recovery vault and required policies
resource "azurerm_recovery_services_vault" "site_recovery" {
  for_each = local.asr_vaults

  name                = each.key
  location            = each.value.target_location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  sku                 = each.value.sku
  soft_delete_enabled = each.value.soft_delete_enabled
}

# create primary recovery fabric
resource "azurerm_site_recovery_fabric" "site_recovery" {
  for_each = local.asr_vaults

  name                = "${each.key}-primary-fabric"
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  recovery_vault_name = each.key
  location            = each.value.primary_location
  depends_on = [
    azurerm_recovery_services_vault.site_recovery
  ]
}

# create secondary recovery fabric
resource "azurerm_site_recovery_fabric" "site_recovery_sec" {
  for_each = local.asr_vaults

  name                = "${each.key}-secondary-fabric"
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  recovery_vault_name = each.key
  location            = each.value.target_location
  depends_on = [
    azurerm_recovery_services_vault.site_recovery
  ]
}

# create policy
resource "azurerm_site_recovery_replication_policy" "site_recovery" {
  for_each = {
    for k, vault in local.asr_vaults : k => vault if vault.policy.name != null
  }

  name                                                 = each.value.policy.name
  resource_group_name                                  = each.value.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.site_recovery[each.key].name
  recovery_point_retention_in_minutes                  = each.value.policy.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = each.value.policy.application_consistent_snapshot_frequency_in_minutes
}

output "fabrics" {
  value = {
    primary_fabrics    = azurerm_site_recovery_fabric.site_recovery
    secondary_fabrics  = azurerm_site_recovery_fabric.site_recovery_sec
    replication_policy = azurerm_site_recovery_replication_policy.site_recovery
  }
}
