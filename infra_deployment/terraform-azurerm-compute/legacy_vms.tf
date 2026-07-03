#
# "Legacy" VMs
#
# Support fo the "legacy" azurerm_virtual_machine capability was added to support
# a customer where a custom image included additional data disks.  The new OS specific
# vm resource types don't support this.  
#
# The current version o this code supports only a limited feature set.  Additional features
# can be added as and when projects required them

# generate the list of legacy vms - this uses the same data block as the standard vm capabilities
locals {
  legacy_vms = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in lookup(group_data, "hosts", []) : merge(
        {
          hostname                     = lower(host_key)
          backup_policy                = null
          asr_policy                   = null
          availability_set             = null
          ppg_name                     = null
          disks                        = []
          nics                         = lookup(host_data, "nics", [{}])
          enable_boot_diagnostics      = false
          os_disk_storage_account_type = "Premium_LRS"
          resource_group_name          = try(group_data.resource_group_name, local.default_resource_group.name)
          location                     = try(group_data.location, local.default_resource_group.location)
          os_disk_size                 = null
          license_type                 = null
        },
        group_data,
        {
          zone = try(host_data.zone, null)
          tags = merge(
            local.tags,
            try(group_data.tags, {}),
            try(host_data.tags, {})
          )
          os_account = merge(
            local.os_account,
            try(host_data.os_account, {})
          )
          # generate a list of storage disks including generation of disk names and lun assignments
          storage_data_disks = flatten(
            [
              for disk in try(group_data.disks, []) : [
                for lun in try(disk.luns, [disk.lun]) : merge(
                  {
                    caching                   = "None"
                    create_option             = "Empty"
                    disk_size                 = null
                    write_accelerator_enabled = false
                    storage_account_type      = "Premium_LRS"
                  },
                  disk,
                  {
                    lun  = lun
                    name = "${lower(host_key)}_${disk.name}${format("%02d", try(index(disk.luns, lun), disk.lun) + 1)}"
                  }
                )
              ]
            ]
          )
        }
      )
    ] if try(group_data.legacy, false)
  ])
}

# create the required virtual machines
resource "azurerm_virtual_machine" "legacy_vms" {
  for_each = {
    for vm in local.legacy_vms : vm.hostname => vm
  }

  name = lower(each.value.hostname)

  # assocaited VM with resource group
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location

  network_interface_ids = flatten(
    [
      for nic in local.nics : [
        azurerm_network_interface.network_interfaces[nic.name].id
      ] if nic.hostname == each.value.hostname
    ]
  )

  vm_size = each.value.sku

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = each.value.image_details.resource_id
  }

  storage_os_disk {
    name              = "${lower(each.value.hostname)}_os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = each.value.os_disk_storage_account_type
  }

  os_profile {
    computer_name  = lower(each.value.hostname)
    admin_username = each.value.os_account.admin_username
    admin_password = (
      each.value.os_account.password_key_vault != null ?
      data.azurerm_key_vault_secret.os_account[0].value : try(var.secrets[regex("secret:(.*)", each.value.os_account.admin_password)[0]], each.value.os_account.admin_password)
    )
  }

  # for legacy VMs, we have to generate the disk configuration "inline" rather than as individual resources
  # this allows some disks to take their data from the machine image
  dynamic "storage_data_disk" {
    for_each = each.value.storage_data_disks
    content {
      name                      = storage_data_disk.value.name
      caching                   = storage_data_disk.value.caching
      create_option             = storage_data_disk.value.create_option
      disk_size_gb              = storage_data_disk.value.disk_size
      lun                       = storage_data_disk.value.lun
      write_accelerator_enabled = storage_data_disk.value.write_accelerator_enabled
      managed_disk_type         = storage_data_disk.value.storage_account_type
    }
  }

  dynamic "os_profile_linux_config" {
    for_each = each.value.os_type == "linux" ? [1] : []
    content {
      disable_password_authentication = each.value.os_account.ssh_key_file != null ? true : false

      dynamic "ssh_keys" {
        for_each = each.value.os_account.ssh_key_file != null ? [1] : []
        content {
          key_data = file(each.value.os_account.ssh_key_file)
          path     = "/home/${each.value.os_account.admin_username}/.ssh/authorized_keys"
        }
      }
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = each.value.os_type == "windows" ? [1] : []
    content {
      provision_vm_agent = true
    }
  }

  tags = each.value.tags
}
/*
*/