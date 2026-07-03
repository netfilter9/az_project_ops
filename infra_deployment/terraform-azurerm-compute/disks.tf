#
# Disk
#
# Our DRY (don't repeat yourself) architecture approach means that we need
# to generate the complete list of disks required with the right settings 
# from minimal inputs.  This will be a multi step process
#
# We also need to handle a complex set of default and overrides
#

locals {

  # First handle disks where we provide the number required rather than a list of luns

  # step 1: expand the disk information for each group
  # this creates a full list of disks rather than a count for each disk type
  expanded_disks = {
    for group_key, group_data in try(var.deployment.server_groups, {}) : group_key => flatten([
      for disk in merge({ disks = [] }, group_data).disks : [
        for index in range(disk.number_of_disks) : merge(
          {
            storage_account_type      = "Premium_LRS"
            caching                   = lookup(local.standards.data.disks, disk.name, { caching = "None" }).caching
            write_accelerator_enabled = lookup(lookup(local.standards.data.disks, disk.name, {}), "write_accelerator_enabled", false)
            resource_group_name       = try(group_data.resource_group_name, local.default_resource_group.name)
            location                  = try(group_data.location, local.default_resource_group.location)
            tier                      = try(disk.tier, null)
            on_demand_bursting_enabled = false
          },
          disk,
          {
            #name = disk.name=="export_BP101_bkp" ? disk.name : "${disk.name}${format("%02d", index + 1)}",
            name = disk.name=="export_BP101_bkp" ? disk.name : "${disk.name}",
          }
        )
      ] if can(disk.number_of_disks)
    ]) if !try(group_data.legacy, false) # "legacy" vms have their disks created inline
  }

  # step 2: assign a unique lun number to each disk and enhance the data
  # with additional caching and write accelaration values from our best practice
  expanded_disks_with_lun = {
    for group_key, group_data in local.expanded_disks : group_key => [
      for index in range(length(group_data)) : merge(
        {
          lun = index
        },
        group_data[index]
      )
    ]
  }

  # step 3: calculate the full array of disks for each individual machine
  disks = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in group_data.hosts : [
        for disk in try(local.expanded_disks_with_lun[group_key], []) : merge(
          disk,
          {
            os_type  = group_data.os_type
            hostname = host_key
            zone     = merge({ zone = null }, host_data).zone
            #name     = "${lower(host_key)}-${disk.name}"
            name     = "${disk.name}"
            tags     = try("${disk.tags}", {})
            #tags = merge(
            #  local.tags,
            #  try(group_data.tags, {}),
            #  try(host_data.tags, {})
            #  
            #)
          }
        )
      ]
    ]
  ])

  # next assign disks where the lun numbers are provided rather than the number of disks

  # step 1: calculate disks required based on lun numbers
  expanded_disks_with_lun2 = {
    for group_key, group_data in try(var.deployment.server_groups, {}) : group_key => flatten([
      for disk in merge({ disks = [] }, group_data).disks : [
        for lun in disk.luns : merge(
          {
            storage_account_type      = "Premium_LRS"
            caching                   = lookup(local.standards.data.disks, disk.name, { caching = "None" }).caching
            write_accelerator_enabled = lookup(lookup(local.standards.data.disks, disk.name, {}), "write_accelerator_enabled", false)
            resource_group_name       = try(group_data.resource_group_name, local.default_resource_group.name)
            location                  = try(group_data.location, local.default_resource_group.location)
            tier                      = try(disk.tier, null)
          },
          disk,
          {
            #name = "${disk.name}${format("%02d", index(disk.luns, lun) + 1)}",
            name = "${disk.name}",
            lun  = lun
          }
        )
      ] if can(disk.luns)
    ]) if !try(group_data.legacy, false) # "legacy" vms have their disks created inline
  }

  # step 2: expand to create machine specific instances
  disks2 = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in group_data.hosts : [
        for disk in try(local.expanded_disks_with_lun2[group_key], []) : merge(
          disk,
          {
            os_type  = group_data.os_type
            hostname = host_key
            zone     = merge({ zone = null }, host_data).zone
            #name     = "${lower(host_key)}-${disk.name}"
            name     = "${disk.name}"
            tags     = try("${disk.tags}", {})
            #tags = merge( 
            #  local.tags,             
            #  try(group_data.tags, {}),
            #  try(host_data.tags, {})
            #  
            #  
            #)
          }
        )
      ]
    ]
  ])

  # combine all disks into one group for deployment
  disks_all = concat(
    local.disks,
    local.disks2
  )
}

output "expanded_disks_with_lun2" {
  value = local.expanded_disks_with_lun2
}

# debug outputs
output "expanded_disks" {
  value = local.expanded_disks
}

output "expanded_disks_with_lun" {
  value = local.expanded_disks_with_lun
}

output "disks" {
  value = local.disks
}

# create a managed disk for each item in the array
resource "azurerm_managed_disk" "disks" {
  for_each = {
    for disk in local.disks_all : disk.name => disk
  }

  name                 = each.value.name
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size
  location             = each.value.location
  resource_group_name  = local.all_resource_groups[each.value.resource_group_name].name
  storage_account_type = each.value.storage_account_type
  zone                 = each.value.zone
  tier                 = each.value.tier
  tags                 = each.value.tags
  on_demand_bursting_enabled = each.value.on_demand_bursting_enabled

  # NOTE: this fix was introduced to address a specific client requirement involving machine cloning
  # it is not guarenteed that this will remain forever.
  # if it causes problems, either manually taint the disks or contact steven.t.urwin@accenture.com
  lifecycle {
    ignore_changes = [
      create_option,
      source_resource_id,
      hyper_v_generation
    ]
  }
}

# create attachements for all virtual machines machines (linux and windows)
resource "azurerm_virtual_machine_data_disk_attachment" "disks" {
  for_each = {
    for disk in local.disks_all : disk.name => disk
  }

  virtual_machine_id = each.value.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vms[lower(each.value.hostname)].id : azurerm_windows_virtual_machine.windows_vms[lower(each.value.hostname)].id

  managed_disk_id           = azurerm_managed_disk.disks[each.value.name].id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = each.value.write_accelerator_enabled
}
/*
*/
