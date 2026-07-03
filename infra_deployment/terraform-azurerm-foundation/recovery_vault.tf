#
# Recovery Vault
#
# This file contains all the resource definitions required to provision 
# recovery vaults
#
# TODO: Need to review this logic as one project reported issues with it
#
# Logic Overview:
# * Generate a list of recovery vaults to create
# * Create them
# * Generate the list of backup policies required for each vault
# * Create them

# create a list of recovery vaults to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  recovery_vaults = {
    for k, v in try(var.foundation.recovery_vaults, {}) : k => merge(
      {
        # overrideable defaults     
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        storage_mode_type = "LocallyRedundant"
        soft_delete_enabled = false
      },
      v,
      {
        # fixed values and internal references
        sku                 = "Standard"
        # soft_delete_enabled = true   
      }
    ) if try(v.is_asr, false) == false
  }
}

# create recovery vault and required policies
resource "azurerm_recovery_services_vault" "recovery_vault" {
  for_each = local.recovery_vaults

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  sku                 = each.value.sku
  soft_delete_enabled = each.value.soft_delete_enabled
  storage_mode_type   = each.value.storage_mode_type
}

locals {
  backup_policies = {
    for entry in flatten([
      for k, v in local.recovery_vaults : [
        for policy_k, policy_v in v.policies : merge(
          v,
          {
            name                = policy_k
            backup_frequency    = "Daily"
            backup_time         = "23:00"
            timezone            = "UTC"
            recovery_vault_name = azurerm_recovery_services_vault.recovery_vault[k].name
            retention_daily     = null
            retention_weekly    = null
            retention_monthly   = null
            retention_yearly    = null
          },
          policy_v
        )
      ]
    ]) : "${entry.recovery_vault_name}-${entry.name}" => entry
  }
}

#Create Backup Policies
resource "azurerm_backup_policy_vm" "recovery_vault" {
  for_each = local.backup_policies

  name                = each.value.name
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  recovery_vault_name = each.value.recovery_vault_name
  timezone            = each.value.timezone
  backup {
    frequency = each.value.backup_frequency
    time      = each.value.backup_time
  }
  dynamic "retention_daily" {
    for_each = each.value.retention_daily != null ? [1] : []

    content {
      count = each.value.retention_daily.count
    }
  }
  dynamic "retention_weekly" {
    for_each = each.value.retention_weekly != null ? [1] : []

    content {
      count    = each.value.retention_weekly.count
      weekdays = each.value.retention_weekly.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = each.value.retention_monthly != null ? [1] : []

    content {
      count    = each.value.retention_monthly.count
      weekdays = each.value.retention_monthly.weekdays
      weeks    = each.value.retention_monthly.weeks
    }
  }

  dynamic "retention_yearly" {
    for_each = each.value.retention_yearly != null ? [1] : []

    content {
      count    = each.value.retention_yearly.count
      weekdays = each.value.retention_yearly.weekdays
      weeks    = each.value.retention_yearly.weeks
      months   = each.value.retention_yearly.months
    }
  }
}
/*
*/