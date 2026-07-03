#
# Storage
#
# This file contains definitions for the creation of storage accounts and
# other associated components
#
# Logic Overview:
# * Generate a list of storage accounts to create
# * Create them (as long as they are not lookups)
# * Lookup up each storage account 
# * Generate the list of storage account network rules assocaited with each SA
# * Create them 
# * Create a list of any containers to create in each storage account
# * Create them
# * Create a list of blobs to create for each storage account
# * Create them
# * Create a list of fileshares to create for each storage account
# * Create them
# * Create a list of management policies for each storage account
# * Create them
# * TODO: need work out of the end point logic is valid or not

# create a list of storage accounts to create by combining
# defaults, inputs, fixed values and internal references  
locals {
    storage_accounts = {
        for k, v in try(var.deployment.storage_accounts, {}) : k => merge(
            {
                lookup                            = false
                account_tier                      = "Standard"
                account_kind                      = "StorageV2"
                enable_https_traffic_only         = true
                account_replication_type          = "LRS"
                min_tls_version                   = "TLS1_2"
                rule                              = null
                containers                        = {}
                fileshares                        = {}
                queues                            = {}
                tables                            = {}
                data_lake_fss                     = {}
                resource_group_name               = local.default_resource_group.name
                location                          = local.default_resource_group.location
                create_rules_as_resources         = false
                allow_nested_items_to_be_public   = false
                infrastructure_encryption_enabled = false
                large_file_share_enabled          = false
                shared_access_key_enabled         = true
                is_hns_enabled                    = false
            },
            v,
            {
                network_rules = {
                    for rule_k, rule_v in try(v.network_rules, {}) : rule_k => merge(
                        {
                            default_action = "Deny"
                            ip_rules       = []
                            bypass         = []
                        },
                        rule_v,
                        {
                            virtual_network_subnet_ids = [
                                for subnet in rule_v.subnets : try(subnet.subnet_id, data.azurerm_subnet.lookups["${subnet.subnet}"].id) 
                            ]
                        }
                    )
                }
                tags = merge(
                    try(var.deployment.tags, {}),
                    try(v.tags, {})
                )
            }
        )
    }
}

# create storage accounts
resource "azurerm_storage_account" "storage" {
    for_each = {
        for k, v in local.storage_accounts : k => v if !v.lookup
    }

    name                              = each.key
    resource_group_name               = local.all_resource_groups[each.value.resource_group_name].name 
    location                          = each.value.location
    account_tier                      = each.value.account_tier
    account_kind                      = each.value.account_kind
    account_replication_type          = each.value.account_replication_type
    enable_https_traffic_only         = each.value.enable_https_traffic_only
    is_hns_enabled                    = each.value.is_hns_enabled
    min_tls_version                   = each.value.min_tls_version
    allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
    infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
    large_file_share_enabled          = each.value.large_file_share_enabled
    shared_access_key_enabled         = each.value.shared_access_key_enabled

    dynamic "network_rules" {
        for_each = each.value.create_rules_as_resources ? {} : each.value.network_rules

        content {
            default_action              = network_rules.value.default_action
            ip_rules                    = network_rules.value.ip_rules
            virtual_network_subnet_ids  = network_rules.value.virtual_network_subnet_ids
            bypass                      = network_rules.value.bypass
        }
    }

    dynamic "blob_properties" {
        for_each = try([each.value.blob_properties], [])

        content {
            dynamic "delete_retention_policy" {
                for_each = try([blob_properties.value.delete_retention_policy], [])

                content {
                    days = delete_retention_policy.value.days
                }
            }

            dynamic "container_delete_retention_policy" {
                for_each = try([blob_properties.value.container_delete_retention_policy], [])

                content {
                    days = container_delete_retention_policy.value.days
                }
            }
        }
    }

    tags = each.value.tags
}

# lookup the storage accounts
data "azurerm_storage_account" "storage" {
    for_each = {
        for k, v in local.storage_accounts : k => v if v.lookup
    }

    name                = each.key
    resource_group_name = each.value.resource_group_name

    # depends on required as we may lookup and existing storage account
    depends_on = [azurerm_storage_account.storage]
}

locals {
    all_storage_accounts = merge(
        azurerm_storage_account.storage,
        data.azurerm_storage_account.storage
    )
}


# calculate any storage account network rules that may be required
locals {
  storage_account_network_rules = flatten(
    [
      for k, v in local.storage_accounts : [
        for rule_k, rule_v in try(v.network_rules, {}) : merge(
          rule_v,
          {
            key                  = "${k}-${rule_k}"
            storage_account_name = k
            resource_group_name  = v.resource_group_name
          }
        ) if v.create_rules_as_resources
      ]
    ]
  )
}

# create network rule for storage account
# Note: you can only have at most one per account
resource "azurerm_storage_account_network_rules" "storage" {
  for_each = {
    for entry in local.storage_account_network_rules : entry.key => entry
  }

  storage_account_id         = local.all_storage_accounts[each.value.storage_account_name].id
  default_action             = each.value.default_action
  virtual_network_subnet_ids = each.value.virtual_network_subnet_ids
  bypass                     = each.value.bypass
  ip_rules                   = each.value.ip_rules

  depends_on = [azurerm_storage_account.storage]
}

# calculate storage account container and blob definitions
locals {
  containers = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for container_key, container_data in sa_data.containers : merge(
          {
            container_name       = container_key
            storage_account_name = sa_key
          },
          container_data,
          {
            container_access_type = "private"
          }
        )
      ]
    ]) : "${entry.storage_account_name}-${entry.container_name}" => entry
  }
}

# create storage containers as required
resource "azurerm_storage_container" "storage" {
  for_each = local.containers

  name                  = each.value.container_name
  storage_account_name  = azurerm_storage_account.storage[each.value.storage_account_name].name
  container_access_type = each.value.container_access_type
}

# expand out blobs if required
locals {
  blobs = {
    for entry in flatten([
      for container_key, container_data in local.containers : [
        for blob_key, blob_data in try(container_data.blobs, {}) : {
          storage_container_name = container_data.container_name
          storage_account_name   = container_data.storage_account_name
          file                   = blob_data.file
          id                     = blob_key
          type                   = "Block"
        }
      ]
    ]) : "${entry.storage_account_name}-${entry.storage_container_name}-${entry.id}" => entry
  }
}


# create blobs as required
resource "azurerm_storage_blob" "storage" {
  for_each = local.blobs

  name                   = each.value.file
  storage_account_name   = azurerm_storage_account.storage[each.value.storage_account_name].name
  storage_container_name = azurerm_storage_container.storage["${each.value.storage_account_name}-${each.value.storage_container_name}"].name
  type                   = each.value.type
  source                 = each.value.file
}


# calculate storage account fileshares
locals {
  fileshares = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for fs_key, fs_data in sa_data.fileshares : {
          fileshare_name       = fs_key
          storage_account_name = sa_key
          quota                = try(fs_data.quota, "5120")
          enabled_protocol     = try(fs_data.enabled_protocol, "SMB")
        }
      ]
    ]) : "${entry.storage_account_name}-${entry.fileshare_name}" => entry
  }
}

# create sotrage fileshares as required
resource "azurerm_storage_share" "storage" {
  for_each = local.fileshares

  name                 = each.value.fileshare_name
  storage_account_name = azurerm_storage_account.storage[each.value.storage_account_name].name
  quota                = each.value.quota
  enabled_protocol     = each.value.enabled_protocol
}

# calculate storage account queues
locals {
  queues = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for q_key, q_data in sa_data.queues : {
          queue_name           = q_key
          storage_account_name = sa_key
        }
      ]
    ]) : "${entry.storage_account_name}-${entry.queue_name}" => entry
  }
}

# create storage queues as required
resource "azurerm_storage_queue" "storage" {
  for_each = local.queues

  name                 = each.value.queue_name
  storage_account_name = azurerm_storage_account.storage[each.value.storage_account_name].name
}

# calculate storage account tables
locals {
  tables = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for table_key, table_data in sa_data.tables : {
          table_name           = table_key
          storage_account_name = sa_key
        }
      ]
    ]) : "${entry.storage_account_name}-${entry.table_name}" => entry
  }
}

# create storage tables as required
resource "azurerm_storage_table" "storage" {
  for_each = local.tables

  name                 = each.value.table_name
  storage_account_name = azurerm_storage_account.storage[each.value.storage_account_name].name
}

# calculate storage account data lake gen2 file system
locals {
  data_lake_fss = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for dl_fs_key, dl_fs_data in sa_data.data_lake_fss : {
          dl_fs_name           = dl_fs_key
          storage_account_name = sa_key
          path                 = try(dl_fs_data.path, null)
        }
      ]
    ]) : "${entry.storage_account_name}-${entry.dl_fs_name}" => entry
  }
}

# create storage account data lake gen2 file system as required
resource "azurerm_storage_data_lake_gen2_filesystem" "storage" {
  for_each = local.data_lake_fss

  name               = each.value.dl_fs_name
  storage_account_id = azurerm_storage_account.storage[each.value.storage_account_name].id
}

# create storage account data lake gen2 path as required
resource "azurerm_storage_data_lake_gen2_path" "storage" {
  #for_each = local.data_lake_fss 
  for_each = {
    for k, v in local.data_lake_fss : k => v if v.path != null
  }

  path               = each.value.path
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.storage["${each.value.storage_account_name}-${each.value.dl_fs_name}"].name
  storage_account_id = azurerm_storage_account.storage[each.value.storage_account_name].id
  resource           = "directory"
}

# TODO rewrite this to better reflect standards
# create storage life management policy when required
resource "azurerm_storage_management_policy" "storage" {
  for_each = {
    for k, v in local.storage_accounts : k => v if lookup(v, "management_policy", {}) != {}
  }
  storage_account_id = azurerm_storage_account.storage[each.key].id

  dynamic "rule" {
    for_each = lookup(each.value.management_policy, "rules", [])

    content {
      name    = rule.value.name
      enabled = lookup(rule.value, "enabled", true)
      filters {
        prefix_match = rule.value.filter.prefix_match
        blob_types   = lookup(rule.value.filter, "blob_types", ["blockBlob"])
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = try(rule.value.action.base_blob.tier_to_cool_after_days_since_modification_greater_than, 10)
          tier_to_archive_after_days_since_modification_greater_than = try(rule.value.action.base_blob.tier_to_archive_after_days_since_modification_greater_than, 50)
          delete_after_days_since_modification_greater_than          = try(rule.value.action.base_blob.delete_after_days_since_modification_greater_than, 100)
        }
        snapshot {
          delete_after_days_since_creation_greater_than = try(rule.value.action.snapshot.delete_snapshot_after, 30)
        }
      }
    }
  }
}

locals {
  private_endpoints = {
    for entry in flatten([
      for sa_key, sa_data in local.storage_accounts : [
        for private_endpoint_key, private_endpoint_data in try(sa_data.private_endpoints, {}) : merge(
          {
            storage_account_name            = sa_key
            name                            = private_endpoint_key
            private_service_connection_name = "${private_endpoint_key}-psc"
            is_manual_connection            = false
            location                        = try(sa_data.location, local.default_resource_group.location)
            resource_group_name             = try(sa_data.resource_group_name, local.default_resource_group.name)
            tags                            = sa_data.tags
          },
          private_endpoint_data,
          {
            subnet_id                      = data.azurerm_subnet.lookups["${private_endpoint_data.network.subnet}"].id
            private_connection_resource_id = local.all_storage_accounts[sa_key].id
          }
        )
      ]
    ]) : "${entry.storage_account_name}-${entry.name}" => entry
  }
}

# create private endpoint for storage account
resource "azurerm_private_endpoint" "storage" {
  for_each = local.private_endpoints

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  # subnet lookup can be improve in future
  subnet_id = each.value.subnet_id

  private_service_connection {
    name                           = each.value.private_service_connection_name
    private_connection_resource_id = each.value.private_connection_resource_id
    is_manual_connection           = each.value.is_manual_connection
    #subresource_names takes list of string, but it permits only one string value in the list
    subresource_names              = each.value.subresource_names
  }

  tags = each.value.tags
}

# storage diagnostics handling
locals {
  # defaults dignostics categories to use if no settings are specified
  storage_default_diagnostics_settings = {
    account = {
      metrics = ["Transaction", "Capacity"]
      logs    = []
    }

    blob = {
      metrics = ["Transaction", "Capacity"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }

    queue = {
      metrics = ["Transaction", "Capacity"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }

    table = {
      metrics = ["Transaction", "Capacity"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }

    file = {
      metrics = ["Transaction", "Capacity"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }
  }

  # used to determine target resource in azure
  storage_diagnostics_extensions = {
    account = ""
    blob    = "/blobServices/default/"
    queue   = "/queueServices/default/"
    table   = "/tableServices/default/"
    file    = "/fileServices/default/"
  }

  # calculation of required diagnostics categories
  storage_diagnostics_settings = flatten(
    [
      for k, v in local.storage_accounts : [
        for settings_k, settings_v in try(v.diagnostics.settings, local.storage_default_diagnostics_settings) : merge(
          {
            enabled = true
          },
          v,
          {
            type                       = settings_k
            name                       = "${k}-${settings_k}-diag"
            target_resource_id         = "${azurerm_storage_account.storage[k].id}${local.storage_diagnostics_extensions[settings_k]}"
            logs                       = try(settings_v.logs, [])
            metrics                    = try(settings_v.metrics, [])
            log_analytics_workspace_id = try(data.azurerm_log_analytics_workspace.diagnostics[0].id, null)
            storage_account_id         = try(data.azurerm_storage_account.diagnostics[v.diagnostics.storage_account_name].id, null)
            retention_policy = try(
              settings_v.retention_policy,
              v.diagnostics.retention_policy,
              {}
            )
          }
        )
      ] if(try(v.diagnostics, {}) != {} && !v.lookup)
    ]
  )
}

#create moniter diagnostic setting component
resource "azurerm_monitor_diagnostic_setting" "storage" {
  for_each = {
    for item in local.storage_diagnostics_settings : item.name => item
  }

  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id
  storage_account_id         = each.value.storage_account_id

  dynamic "log" {
    for_each = local.storage_default_diagnostics_settings[each.value.type].logs

    content {
      category = log.value
      enabled  = contains(each.value.logs, log.value) ? true : false

      #retention policy if defined, else default
      retention_policy {
        enabled = contains(each.value.logs, log.value) ? try(each.value.retention_policy.enabled, false) : false
        days    = contains(each.value.logs, log.value) ? try(each.value.retention_policy.days, 30) : 0
      }
    }
  }

  dynamic "metric" {
    for_each = local.storage_default_diagnostics_settings[each.value.type].metrics

    content {
      category = metric.value
      enabled  = contains(each.value.metrics, metric.value) ? true : false

      #retention policy if defined, else default
      retention_policy {
        enabled = contains(each.value.metrics, metric.value) ? try(each.value.retention_policy.enabled, false) : false
        days    = contains(each.value.metrics, metric.value) ? try(each.value.retention_policy.days, 30) : 0
      }
    }
  }
}
