#
# Key Vault
#
# This file provides all the resources definitions required in order to provision
# a keyvault
#
# WARNING: This file requires a design review as theapproach for securely locking 
# down a key vault is not clear
#
# Logic overview:
# * Generate a list of key vaults to create
# * Create them
# * Generate a list of access policies to apply to each key vault
# * Apply them 
# * TODO: If we need logic to generate secure random passwords, we cloud add it

# create a list of key vaults to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  key_vaults = {
    for k, v in try(var.foundation.key_vaults, {}) : k => merge(
      {
        # overrideable defaults
        key                             = k
        location                        = local.default_resource_group.location
        resource_group_name             = local.default_resource_group.name
        enable_rbac_authorization       = null
        purge_protection_enabled        = null
        network_acls                    = null
        key_permissions                 = []
        secret_permissions              = []
        certificate_permissions         = []
        sku_name                        = "standard"
        enabled_for_deployment          = false
        enabled_for_disk_encryption     = false
        enabled_for_template_deployment = false
        soft_delete_retention_days      = 90
      },
      v,
      {
        # internal references and fixed value
        tenant_id = data.azurerm_client_config.current.tenant_id
        tags = merge(
          try(var.foundation.tags, {}),
          try(v.tags, {})
        )
      }
    )
  }

  key_vault_private_endpoints = flatten([
    for key_vault in local.key_vaults : merge(
      {
        key_vault_key    = key_vault.key
        key              = key_vault.key
        subresource_name = "vault"
      },
      try(key_vault.private_endpoint, {}),
    ) if try(key_vault.private_endpoint, null) != null
  ])

  access_policies = flatten([
    for kv in local.key_vaults : [
      for access_policy_k, access_policy_v in try(kv.access_policies, {}) : merge(
        {
          key_vault_name    = kv.key
          object_id         = access_policy_k
          access_policy_key = "${kv.key}-${access_policy_k}"
        },
        access_policy_v,
        {

        }
      )
    ]
  ])
}

# create a keyvault(s)
resource "azurerm_key_vault" "key_vault" {
  for_each = local.key_vaults

  name                            = each.key
  location                        = each.value.location
  resource_group_name             = local.all_resource_groups[each.value.resource_group_name].name
  sku_name                        = each.value.sku_name
  enable_rbac_authorization       = each.value.enable_rbac_authorization
  purge_protection_enabled        = each.value.purge_protection_enabled
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  soft_delete_retention_days      = each.value.soft_delete_retention_days

  # TODO - need to investigate this
  tenant_id = each.value.tenant_id

  dynamic "network_acls" {
    for_each = try(each.value.network_acls, null) != null ? [1] : []
    content {
      bypass         = each.value.network_acls.bypass
      default_action = each.value.network_acls.default_action

      virtual_network_subnet_ids = flatten(
        [
          for network in try(each.value.network_acls.networks, []) : [
            for subnet in try(network.subnets, []) :
            data.azurerm_subnet.networks["${network.network}-${subnet}"].id
          ]
        ]
      )

      ip_rules = try(each.value.network_acls.ip_rules, [])
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     network_acls
  #   ]
  # }

  tags = each.value.tags

}

# apply key vault access policies to each key vault
resource "azurerm_key_vault_access_policy" "key_vault" {
  for_each = {
    for entry in local.access_policies : entry.access_policy_key => entry
  }

  key_vault_id            = azurerm_key_vault.key_vault[each.value.key_vault_name].id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = each.value.object_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
}

/*
TODO

# create a random password
resource "random_password" "key_vault" {
  length    = 16
  special   = true
  min_upper = 1
  min_lower = 1
}

# add it to the key vault
resource "azurerm_key_vault_secret" "key_vault" {
  for_each = {
    for k, v in local.management.key_vaults : k => v
  }
  name         = "vmadmin"
  value        = random_password.key_vault.result
  key_vault_id = azurerm_key_vault.key_vault[each.key].id
}
*/