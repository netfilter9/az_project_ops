#
# Network Security Groups
#
# This file contains everything you need to provision
# network security groups
#
# TODO: I'm not convinced that these should live in the foundation 
#
# Logic Overview:
# * Generate a list of network security groups to create
# * Create the network_security_groups
# * Generate a list of network security group rules to create as independent resources
# * Create the network security group rules
# * Generate a list associations to tie the network_security_groups to their related subnets
# * Create the associations
# * Generate a list of  diagnostics settings for each NSG where required
# * Create them
# * TODO: If network watcher defined - generate list of flow logs
# * TODO: Create them

# create a list of network security groups to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  network_security_groups = {
    for k, v in try(var.foundation.network_security_groups, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        diagnostics         = {}
        # allow rule to be defined inline (supports legacy builds)
        use_inline_rules = false
        tags             = try(var.foundation.tags, {})
      },
      v,
      {
        # fixed values and internal references
        # enhance incomming rules to set defaults for optional values
        rules = [
          for rule in concat(var.nsg_default_rules, try(v.rules, [])) : merge(
            {
              source_port_range                       = null
              source_port_ranges                      = null
              destination_port_range                  = null
              destination_port_ranges                 = null
              source_address_prefix                   = null
              source_address_prefixes                 = null
              destination_address_prefix              = null
              destination_address_prefixes            = null
              destination_application_security_groups = null
              source_application_security_groups      = null
              description                             = null
            },
            rule
          )
        ]
      }
    )
  }

  # calculate list of subnets used by network rules - this will be used to perform lookups
  # in the network.tf file
  network_security_group_subnets = flatten(
    [
      for k, v in try(var.foundation.network_security_groups, {}) : [
        for association in try(v.subnet_associations, []) : [
          for subnet in try(association.subnets, []) : {
            resource_group_name  = try(association.resource_group_name, local.default_resource_group.name),
            virtual_network_name = association.network
            subnet               = subnet
          }
        ]
      ]
    ]
  )

  # TODO: I'm not sure this section is needed.
  nsg_application_security_groups = flatten(
    [
      for k, v in try(var.foundation.application_security_groups, {}) : {
        resource_group_name             = try(v.resource_group_name, local.default_resource_group.name),
        application_security_group_name = k
      }
    ]
  )
}
# create network security groups
resource "azurerm_network_security_group" "network_security_groups" {
  for_each = local.network_security_groups

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name

  # inline rules retained for legacy support - ideally, we would not use this
  dynamic "security_rule" {
    for_each = each.value.use_inline_rules ? each.value.rules : []

    content {
      name      = security_rule.value.name
      priority  = security_rule.value.priority
      direction = security_rule.value.direction
      access    = security_rule.value.access
      protocol  = security_rule.value.protocol

      #either range or ranges can be specified
      source_port_range  = security_rule.value.source_port_range
      source_port_ranges = security_rule.value.source_port_ranges

      destination_port_range  = security_rule.value.destination_port_range
      destination_port_ranges = security_rule.value.destination_port_ranges

      #either prefix or prefixes can be specified
      source_address_prefix   = security_rule.value.source_address_prefix
      source_address_prefixes = security_rule.value.source_address_prefixes

      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes

      description = security_rule.value.description
    }
  }

  tags = each.value.tags
}

# build array of rules to apply as independently managed resources (preferred method)
locals {
  network_security_rules = flatten(
    [
      for k, v in try(local.network_security_groups, {}) : [
        for rule in v.rules : merge(
          {
            # overrideable defaults
            resource_group_name         = try(v.resource_group_name, local.default_resource_group.name)
            network_security_group_name = k
            key                         = "${k}-${rule.name}"
          },
          rule
        )
      ] if !v.use_inline_rules
    ]
  )
}

# create rules as independent resources - preferred
resource "azurerm_network_security_rule" "network_security_groups" {
  for_each = {
    for rule in local.network_security_rules : rule.key => rule
  }

  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.network_security_group_name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol

  #either range or ranges can be specified
  source_port_range  = each.value.source_port_range
  source_port_ranges = each.value.source_port_ranges

  destination_port_range  = each.value.destination_port_range
  destination_port_ranges = each.value.destination_port_ranges

  #either prefix or prefixes can be specified
  source_address_prefix   = each.value.source_address_prefix
  source_address_prefixes = each.value.source_address_prefixes

  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes

  destination_application_security_group_ids = each.value.destination_application_security_groups == null ? null : [
    for group in try(each.value.destination_application_security_groups, []) : data.azurerm_application_security_group.application_security_groups[group].id
  ]

  source_application_security_group_ids = each.value.source_application_security_groups == null ? null : [
    for group in try(each.value.source_application_security_groups, []) : data.azurerm_application_security_group.application_security_groups[group].id
  ]

  description = each.value.description

  depends_on = [azurerm_network_security_group.network_security_groups, azurerm_application_security_group.application_security_groups]
}

# calculate network security group assocaitions if required
locals {
  subnet_nsg_associations = flatten(
    [
      for k, v in local.network_security_groups : [
        for entry in v.subnet_associations : [
          for subnet in entry.subnets : {
            subnet_key = "${entry.network}-${subnet}"
            nsg        = k
            key        = "${k}-${entry.network}-${subnet}"
          }
        ]
      ]
    ]
  )
}

# create required associations
resource "azurerm_subnet_network_security_group_association" "network_security_groups" {
  for_each = {
    for entry in local.subnet_nsg_associations : entry.key => entry
  }

  subnet_id                 = data.azurerm_subnet.networks[each.value.subnet_key].id
  network_security_group_id = azurerm_network_security_group.network_security_groups[each.value.nsg].id

  depends_on = [
    azurerm_subnet.networks
  ]
}

# query diagnostics settings
data "azurerm_monitor_diagnostic_categories" "network_security_groups" {
  for_each = local.network_security_groups

  resource_id = azurerm_network_security_group.network_security_groups[each.key].id
}

locals {
  network_security_groups_diagnostics_settings = {
    for k, v in try(var.foundation.network_security_groups, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
      },
      v,
      {
        name               = "${k}-diagnostic-setting"
        target_resource_id = azurerm_network_security_group.network_security_groups[k].id
        logs               = data.azurerm_monitor_diagnostic_categories.network_security_groups[k].logs
        metrics            = data.azurerm_monitor_diagnostic_categories.network_security_groups[k].metrics
        enabled            = true
        retention_policy = {
          enabled = try(v.diagnostics.storage_account_name, null) != null ? true : false
          days    = try(v.diagnostics.storage_account_name, null) != null ? try(v.diagnostics.retention, 30) : null
        }
        log_analytics_workspace_id = try(data.azurerm_log_analytics_workspace.log_analytics[v.diagnostics.log_analytics_workspace_name].id, null)
        storage_account_id         = try(local.all_storage_accounts[v.diagnostics.storage_account_name].id, null)
      }
    )
    if(try(v.diagnostics, {}) != {})
  }
}

#create moniter diagnostic setting component
resource "azurerm_monitor_diagnostic_setting" "network_security_groups" {
  #if diagnostics object contains "network_security_groups" map, then all the network_security_groups will have diagnostic settings enabled.
  #disable_diagnostics_settings can be set to true for individual nsg, if diagnostic setting not required.  
  for_each = local.network_security_groups_diagnostics_settings

  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id
  storage_account_id         = each.value.storage_account_id

  dynamic "log" {
    for_each = each.value.logs

    content {
      category = log.value
      enabled  = each.value.enabled

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.retention_policy.enabled
        days    = each.value.retention_policy.days
      }
    }
  }

  dynamic "metric" {
    for_each = each.value.metrics

    content {
      category = metric.value
      enabled  = each.value.enabled

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.retention_policy.enabled
        days    = each.value.retention_policy.days
      }
    }
  }
}

# generate a list of flow logs where network watcher is defined for NSG
locals {
  network_watcher_flow_logs = {
    for k, v in local.network_security_groups : k => merge(
      {
        log_name                 = "${k}_flowlogs"
        nsg_name                 = k
        version                  = 2
        retention_days           = 60
        enable_traffic_analytics = false
        enabled                  = true
        retention_policy = {
          enabled = true
          days    = 7
        }
      },
      v,
      {
        network_security_group_id = azurerm_network_security_group.network_security_groups[k].id
        storage_account_id        = local.all_storage_accounts[v.network_watcher.storage_account_name].id
        workspace_id              = data.azurerm_log_analytics_workspace.log_analytics[v.network_watcher.workspace_name].workspace_id
        workspace_region          = data.azurerm_log_analytics_workspace.log_analytics[v.network_watcher.workspace_name].location
        workspace_resource_id     = data.azurerm_log_analytics_workspace.log_analytics[v.network_watcher.workspace_name].id
        network_watcher_name      = local.all_network_watchers[v.network_watcher.name].name
        resource_group_name       = local.all_network_watchers[v.network_watcher.name].resource_group_name
      }
    ) if try(v.network_watcher, null) != null
  }
}

#Create Network Watcher Flow Logs
resource "azurerm_network_watcher_flow_log" "network_security_groups" {
  for_each = local.network_watcher_flow_logs

  name                      = each.value.log_name
  network_watcher_name      = each.value.network_watcher_name
  resource_group_name       = each.value.resource_group_name
  network_security_group_id = each.value.network_security_group_id
  location                  = each.value.location

  storage_account_id = each.value.storage_account_id
  enabled            = each.value.enabled
  version            = each.value.version

  retention_policy {
    enabled = each.value.retention_policy.enabled
    days    = each.value.retention_policy.days
  }

  dynamic "traffic_analytics" {
    for_each = each.value.enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = each.value.workspace_id
      workspace_region      = each.value.workspace_region
      workspace_resource_id = each.value.workspace_resource_id
    }
  }
}
/*
*/