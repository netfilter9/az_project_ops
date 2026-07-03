#
# Shared Disks
#
# Our DRY (don't repeat yourself) architecture approach means that we need
# to generate the complete list of disks required with the right settings 
# from minimal inputs.  This will be a multi step process
#
# We also need to handle a complex set of default and overrides
#
# Note: servers which share disks should be placed in a proximity placement 
# group to ensure that they share the same network spine.  Failure to do so
# may result in errors.
#

locals {
  # step 1: expand the disk information for each group
  # this creates a full list of disks rather than a count for each disk type
  expanded_shared_disks = {
    for group_key, group_data in try(var.deployment.server_groups, {}) : group_key => flatten([
      for disk in try(group_data.shared_disks, []) : [
        for index in range(disk.number_of_disks) : merge(
          {
            storage_account_type      = "Premium_LRS"
            caching                   = lookup(local.standards.data.disks, disk.name, { caching = "None" }).caching
            write_accelerator_enabled = lookup(lookup(local.standards.data.disks, disk.name, {}), "write_accelerator_enabled", false)
            resource_group_name       = try(group_data.resource_group_name, local.default_resource_group.name)
            location                  = try(group_data.location, local.default_resource_group.location)
            tier                      = try(disk.tier, null)
            shared_lun_offset = sum(flatten(
              [
                0,
                [for disk in try(group_data.disks, []) : disk.number_of_disks]
            ]))
          },
          disk,
          {
            name = "${disk.name}${format("%02d", index + 1)}",
          }
        )
      ]
    ])
  }

  # step 2: assign a unique lun number to each disk and enhance the data
  # with additional caching and write accelaration values from our best practice
  expanded_shared_disks_with_lun = {
    for group_key, group_data in local.expanded_shared_disks : group_key => [
      for index in range(length(group_data)) : merge(
        {
          lun = (index + group_data[index].shared_lun_offset)
        },
        group_data[index]
      )
    ]
  }

  # step3: add additional meta data for the cluster
  shared_disks = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for disk in lookup(local.expanded_shared_disks_with_lun, group_key) : merge(
        {
          max_shares = 2
        },
        disk,
        {
          os_type = group_data.os_type
          name    = "${lower(group_data.cluster_name)}_${disk.name}"
          hosts   = keys(group_data.hosts)
          tags = merge(
            local.tags,
            try(group_data.tags, {})
          )
        }
      )
    ]
  ])

  # step4: calculate the disk associations for each host
  shared_disks_associations = flatten([
    for disk in local.shared_disks : [
      for host in disk.hosts : merge(
        disk,
        {
          association_name = "${host}-${disk.name}"
          hostname         = host
        }
      )
    ]
  ])
}

output "shared_disks_associations" {
  value = local.shared_disks_associations
}

# create a managed disk for each item in the array
resource "azurerm_managed_disk" "shared_disks" {
  for_each = {
    for disk in local.shared_disks : disk.name => disk
  }

  name                 = each.value.name
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size
  location             = each.value.location
  resource_group_name  = local.all_resource_groups[each.value.resource_group_name].name
  storage_account_type = each.value.storage_account_type
  tier                 = each.value.tier
  max_shares           = each.value.max_shares
  tags                 = each.value.tags
}

# create attachements for all virtual machines machines (linux and windows)
resource "azurerm_virtual_machine_data_disk_attachment" "shared_disks" {
  for_each = {
    for disk in local.shared_disks_associations : disk.association_name => disk
  }

  virtual_machine_id = (
    each.value.os_type == "linux" ?
    azurerm_linux_virtual_machine.linux_vms[lower(each.value.hostname)].id :
    azurerm_windows_virtual_machine.windows_vms[lower(each.value.hostname)].id
  )

  managed_disk_id           = azurerm_managed_disk.shared_disks[each.value.name].id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = each.value.write_accelerator_enabled
}
/*
*/
