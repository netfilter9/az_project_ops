#
# Linux VMs
#
# Virtual machine definitions are provided as part of the "server_groups" data
# This allows us to adopt a DRY (don't repeat yourself) approach to defining
# the configuration. 
#
# Azure uses a different terraform resource type for linux and windows so we have to 
# split the data and handle appropriately
#

# generate an exploded list of all required linux vms with their associated group data
# merging in defaults where required, including a single dynamic IP address
# note: zone can be specified either at vm or group level.
locals {
  linux_vms = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in lookup(group_data, "hosts", []) : merge(
        {
          hostname                     = lower(host_key)
          backup_policy                = null
          exclude_disk_luns           = []
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
          encryption_at_host_enabled   = false
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
        }
      )
    ] if group_data.os_type == "linux" && !try(group_data.legacy, false)
  ])
}

# create the required virtual machines
resource "azurerm_linux_virtual_machine" "linux_vms" {
  for_each = {
    for vm in local.linux_vms : vm.hostname => vm
  }

  # Assign basic attributes to VM
  name = lower(each.value.hostname)
  size = each.value.sku
  zone = each.value.zone
  tags = each.value.tags

  # assocaited VM with resource group
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location

  #
  # OS Admin user admin
  # VM specific password keyvault is not yet implemented. We can do it in future if required.
  #
  admin_username = each.value.os_account.admin_username
  admin_password = (
    each.value.os_account.password_key_vault != null ?
    data.azurerm_key_vault_secret.os_account[0].value : try(var.secrets[regex("secret:(.*)", each.value.os_account.admin_password)[0]], each.value.os_account.admin_password)
  )

  disable_password_authentication = each.value.os_account.ssh_key_file != null ? true : false
  # if custom_data has been supplied as a file reference then pass the content of the file as base64 encoded
  custom_data = lookup(each.value.os_account, "custom_data", null) != null ? filebase64(each.value.os_account.custom_data) : null

  # if we have an admin ssh key, this block will be included.
  dynamic "admin_ssh_key" {
    for_each = each.value.os_account.ssh_key_file != null ? [1] : []
    content {
      username   = each.value.os_account.admin_username
      public_key = file(each.value.os_account.ssh_key_file)
    }
  }

  # Set up network cards 
  # This could be improved with a better lookup.
  # We are basically looking for all nics whose names start with the hostname 
  network_interface_ids = flatten(
    [
      for nic in local.nics : [
        azurerm_network_interface.network_interfaces[nic.name].id
      ] if nic.hostname == each.value.hostname
    ]
  )

  # create the right OS disk for this machine
  os_disk {
    #name                 = "${lower(each.value.hostname)}_os"
    name                 = each.value.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_storage_account_type
    disk_size_gb         = each.value.os_disk_size

  }
    encryption_at_host_enabled = each.value.encryption_at_host_enabled
  # 
  # source image selection
  #
  # Enable this block if we are using an image from a shared image gallery
  source_image_id = lookup(each.value.image_details, "resource_id", null)
  license_type    = each.value.license_type

  # or enable this block if we are using a market place image
  dynamic "source_image_reference" {
    for_each = lookup(each.value.image_details, "marketplace_reference", null) != null ? [1] : []
    content {
      publisher = each.value.image_details.marketplace_reference.publisher
      offer     = each.value.image_details.marketplace_reference.offer
      sku       = each.value.image_details.marketplace_reference.sku
      version   = each.value.image_details.marketplace_reference.version
    }
  }

  # or enable this block if we are using a plan image
  dynamic "plan" {
    for_each = lookup(each.value.image_details, "plan", null) != null ? [1] : []
    content {
      name      = each.value.image_details.plan.name
      product   = each.value.image_details.plan.product
      publisher = each.value.image_details.plan.publisher
    }
  }

  # either:
  # * use explicit id
  # * lookup id based on name
  # * or just set to null
  availability_set_id = try(
    each.value.availability_set_id,
    azurerm_availability_set.availability_sets[each.value.availability_set].id,
    null
  )

  virtual_machine_scale_set_id = try(
    each.value.virtual_machine_scale_set_id, null
  )

  # either:
  # * use explicit id
  # * lookup id based on name
  # * lookup based on associated availability set
  # * or just set to null
  proximity_placement_group_id = try(
    each.value.ppg_id,
    azurerm_proximity_placement_group.proximity_placement_groups[each.value.ppg_name].id,
    azurerm_availability_set.availability_sets[each.value.availability_set].proximity_placement_group_id,
    null
  )

  # check control flags to see if we should enable boot diagnostics
# dynamic "boot_diagnostics" {
#    for_each = each.value.enable_boot_diagnostics ? [1] : []
#    content {
#     storage_account_uri = data.azurerm_storage_account.diagnostics[0].primary_blob_endpoint
#    }
#  }

  boot_diagnostics {
        storage_account_uri = null
        
    }

  # proximity placement group references seem to force recreations when they shouldn't so we ignore them
  lifecycle {
    ignore_changes = [
      identity,
      admin_password,
      source_image_id,
      os_disk[0].name
    ]
  }

  # we need all network interfaces to be created before we can create the vms 
  depends_on = [
    azurerm_network_interface.network_interfaces,
    azurerm_network_interface_security_group_association.network_interfaces,
    azurerm_network_interface_application_security_group_association.network_interfaces
  ]
}

# add backups to lunix vms where required
resource "azurerm_backup_protected_vm" "linux_vms" {
  for_each = {
    for vm in local.linux_vms : vm.hostname => vm if vm.backup_policy != null
  }

  resource_group_name = local.foundation.recovery_vault.resource_group_name
  recovery_vault_name = local.foundation.recovery_vault.name
  source_vm_id        = azurerm_linux_virtual_machine.linux_vms[each.key].id
  backup_policy_id    = data.azurerm_backup_policy_vm.lookups[each.value.backup_policy].id
  exclude_disk_luns    = each.value.exclude_disk_luns
}
