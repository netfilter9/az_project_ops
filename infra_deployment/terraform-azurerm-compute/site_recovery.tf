#
# Site Recovery
#
# This file contains definitions for the creation of replicated VM for azure site recovery and
# other associated components
# 
#
#

# setup a recovery plan for an SID
locals {
  recovery_plan = merge(
    {
      vault_name          = null
      resource_group_name = null
      cache_storage       = null
      target_vnet_rg      = null
      target_vnet_name    = null
      target_resource_group = {
        name     = null
        location = null
      }
    },
    local.foundation.asr_vault,
    {
      # state file outputs          
      primary_fabric_id     = var.asr_vault_component == null ? null : var.asr_vault_component.primary_fabric_id
      primary_fabric_name   = var.asr_vault_component == null ? null : var.asr_vault_component.primary_fabric_name
      secondary_fabric_id   = var.asr_vault_component == null ? null : var.asr_vault_component.secondary_fabric_id
      secondary_fabric_name = var.asr_vault_component == null ? null : var.asr_vault_component.secondary_fabric_name
      replication_policy_id = var.asr_vault_component == null ? null : var.asr_vault_component.replication_policy_id
    }
  )
}

# lookup ASR vault
data "azurerm_recovery_services_vault" "site_recovery" {
  count = local.recovery_plan.vault_name != null ? 1 : 0

  name                = local.recovery_plan.vault_name
  resource_group_name = local.recovery_plan.resource_group_name
}

# lookup the target resource group
data "azurerm_resource_group" "site_recovery" {
  count = local.recovery_plan.target_resource_group.name != null ? 1 : 0
  name  = local.recovery_plan.target_resource_group.name
}

# lookup the main virtual network
data "azurerm_virtual_network" "site_recovery" {
  count               = local.recovery_plan.target_vnet_name != null ? 1 : 0
  name                = local.recovery_plan.target_vnet_name
  resource_group_name = local.recovery_plan.target_vnet_rg
}

# lookup the cache storage account
data "azurerm_storage_account" "site_recovery" {
  count = local.recovery_plan.cache_storage != null ? 1 : 0

  name                = local.recovery_plan.cache_storage
  resource_group_name = local.recovery_plan.resource_group_name
}

# lookup the os disks
data "azurerm_managed_disk" "site_recovery" {
  for_each = {
    for vm in concat(local.linux_vms, local.windows_vms) : vm.hostname => vm if vm.asr_policy != null
  }

  name                = "${each.value.hostname}_os"
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  depends_on = [
    azurerm_linux_virtual_machine.linux_vms,
    azurerm_windows_virtual_machine.windows_vms
  ]
}

# create primary container
resource "azurerm_site_recovery_protection_container" "site_recovery" {
  count = local.recovery_plan.vault_name != null ? 1 : 0

  name                 = "${local.recovery_plan.vault_name}-pri-protect-cont"
  resource_group_name  = local.recovery_plan.resource_group_name
  recovery_vault_name  = data.azurerm_recovery_services_vault.site_recovery[0].name
  recovery_fabric_name = local.recovery_plan.primary_fabric_name
}

# create secondary container
resource "azurerm_site_recovery_protection_container" "site_recovery_sec" {
  count = local.recovery_plan.vault_name != null ? 1 : 0

  name                 = "${local.recovery_plan.vault_name}-sec-protect-cont"
  resource_group_name  = local.recovery_plan.resource_group_name
  recovery_vault_name  = data.azurerm_recovery_services_vault.site_recovery[0].name
  recovery_fabric_name = local.recovery_plan.secondary_fabric_name
}

# create container mapping
resource "azurerm_site_recovery_protection_container_mapping" "site_recovery" {
  count = local.recovery_plan.vault_name != null ? 1 : 0

  name                                      = "${local.recovery_plan.vault_name}-container-mapping"
  resource_group_name                       = local.recovery_plan.resource_group_name
  recovery_vault_name                       = data.azurerm_recovery_services_vault.site_recovery[0].name
  recovery_fabric_name                      = local.recovery_plan.primary_fabric_name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.site_recovery[0].name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.site_recovery_sec[0].id
  recovery_replication_policy_id            = local.recovery_plan.replication_policy_id
}


# create availability sets if required
resource "azurerm_availability_set" "site_recovery" {
  for_each = toset([
    for vm in concat(local.linux_vms, local.windows_vms) : vm.availability_set if vm.asr_policy != null
  ])

  name                         = each.key
  location                     = data.azurerm_resource_group.site_recovery[0].location
  resource_group_name          = data.azurerm_resource_group.site_recovery[0].name
  platform_update_domain_count = azurerm_availability_set.availability_sets[each.key].platform_update_domain_count
  platform_fault_domain_count  = azurerm_availability_set.availability_sets[each.key].platform_fault_domain_count
  # proximity_placement_group configuration not available for ASR
  managed = true
}

# create replication instances of the VMs
resource "azurerm_site_recovery_replicated_vm" "site_recovery" {
  for_each = {
    for vm in concat(local.linux_vms, local.windows_vms) : vm.hostname => vm if vm.asr_policy != null
  }

  name                                      = "${each.value.hostname}-vm-replication"
  resource_group_name                       = local.recovery_plan.resource_group_name
  recovery_vault_name                       = data.azurerm_recovery_services_vault.site_recovery[0].name
  source_recovery_fabric_name               = local.recovery_plan.primary_fabric_name
  source_vm_id                              = each.value.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vms[each.value.hostname].id : azurerm_windows_virtual_machine.windows_vms[each.value.hostname].id
  recovery_replication_policy_id            = local.recovery_plan.replication_policy_id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.site_recovery[0].name

  target_resource_group_id                = data.azurerm_resource_group.site_recovery[0].id
  target_recovery_fabric_id               = local.recovery_plan.secondary_fabric_id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.site_recovery_sec[0].id

  target_availability_set_id = each.value.availability_set != null ? azurerm_availability_set.site_recovery[each.value.availability_set].id : null
  target_network_id          = local.recovery_plan.target_vnet_name != null ? data.azurerm_virtual_network.site_recovery[0].id : null

  managed_disk {
    disk_id                    = data.azurerm_managed_disk.site_recovery[each.key].id
    staging_storage_account_id = data.azurerm_storage_account.site_recovery[0].id
    target_resource_group_id   = data.azurerm_resource_group.site_recovery[0].id
    target_disk_type           = data.azurerm_managed_disk.site_recovery[each.key].storage_account_type
    target_replica_disk_type   = data.azurerm_managed_disk.site_recovery[each.key].storage_account_type
  }

  dynamic "managed_disk" {
    for_each = flatten([
      for disk in azurerm_virtual_machine_data_disk_attachment.disks : disk if disk.virtual_machine_id == (each.value.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vms[each.value.hostname].id : azurerm_windows_virtual_machine.windows_vms[each.value.hostname].id)
    ])

    content {
      disk_id                    = managed_disk.value.managed_disk_id
      staging_storage_account_id = data.azurerm_storage_account.site_recovery[0].id
      target_resource_group_id   = data.azurerm_resource_group.site_recovery[0].id
      target_disk_type           = "Standard_LRS"
      target_replica_disk_type   = "Standard_LRS"
    }
  }

  dynamic "network_interface" {
    for_each = each.value.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vms[each.value.hostname].network_interface_ids : azurerm_windows_virtual_machine.windows_vms[each.value.hostname].network_interface_ids

    content {
      source_network_interface_id = network_interface.value
      target_subnet_name          = each.value.subnet
    }
  }
}


