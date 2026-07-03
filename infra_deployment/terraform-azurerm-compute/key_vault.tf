#
# Key vaults
#
# The logic below supports three options
# 1. No key vault associated with the deployment
# 2. The creation of a new key vault specific to this deployment
# 3. A lookup for a single existing key vault
#
# The code today does not support the concept of multiple key vaults
#
# If the creation of a key vault is required, you can optionally seed it with
# secrets where you either provivde the value or specify the use of a generated 
# random password.
#
# Note: Looking up passwords from keyvaults using Terraform can have unpredictable
# results.  If you re-run terraform apply it can result in VMs being recreated rather
# than updated.  It is not recommended.
#

# look up details of executing service principle so we can create correct rules for 
# key vault access
data "azurerm_client_config" "current" {}

# create a local to reference the input keyvault
# reduces rework later if we need to initialise with defaults
locals {
  key_vault = merge(
    {
      sku_name                    = "standard"
      enabled_for_disk_encryption = false
      name                        = null
      secrets                     = []
      resource_group_name         = local.default_resource_group.name
      location                    = local.default_resource_group.location
    },
    try(var.deployment.key_vault, {}),
    {
      tags = merge(
        local.tags,
        try(var.deployment.key_vault.tags, {})
      )
    }
  )
}

# create the key vault if required
resource "azurerm_key_vault" "key_vault" {
  count = local.key_vault.name != null ? 1 : 0

  name                = local.key_vault.name
  resource_group_name = local.all_resource_groups[local.key_vault.resource_group_name].name
  location            = local.key_vault.location

  sku_name                    = local.key_vault.sku_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = local.key_vault.enabled_for_disk_encryption

  # TODO: This requires a security review
  # to be enabled when runing/executing from tooling server 
  #network_acls {
  #  default_action = "Deny"
  #  bypass         = "AzureServices"
  #  virtual_network_subnet_ids = 
  #  [
  #    module.dependencies.common_subnets.sapapp_subnet.id, 
  #    module.dependencies.common_subnets.sapdb_subnet.id,
  #    module.dependencies.common_subnets.infra_subnet.id
  #  ]
  #}

  tags = local.key_vault.tags
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  count = local.key_vault.name != null ? 1 : 0

  key_vault_id = azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge"
  ]

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge"
  ]
}

# generte random password - it doesn't matter if we don't use this
resource "random_password" "key_vault" {
  for_each = {
    for entry in local.key_vault.secrets : entry.name => entry if try(entry.random_password, false)
  }
  length    = 16
  special   = true
  min_upper = 1
  min_lower = 1
}

# add secrets to kevault with random password where required
resource "azurerm_key_vault_secret" "key_vault" {
  for_each = {
    for entry in local.key_vault.secrets : entry.name => entry
  }
  name         = each.key
  value        = try(each.value.random_password, false) ? random_password.key_vault[each.key].result : try(var.secrets[regex("secret:(.*)", each.value.value)[0]], each.value.value)
  key_vault_id = azurerm_key_vault.key_vault[0].id
  tags         = var.deployment.tags
  depends_on   = [azurerm_key_vault_access_policy.key_vault]
}
/*
*/