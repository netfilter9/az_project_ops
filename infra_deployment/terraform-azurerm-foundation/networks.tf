#
# Networks
#
# This file handles the creation of vnets, subnets and their
# associated diagnostics settings
#
# Logic overview:
# * Generate a list of networks to create/lookup
# * Create required networks
# * Perform a lookup for all referenced networks
# * Generate a list of associated subnets
# * Create the subnets
# * Lookup diagnistics settings for the vnets
# * Generate a list of diagnostics config where required
# * Create the diagnostics settings 

# create a list of networks to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  networks = {
    for k, v in try(var.foundation.networks, {}) : k => merge(
      {
        # overrideable defaults
        lookup               = false
        nat_gateway_required = false
        #subnets              = {}
        legacy_subnets      = {}
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        dns_servers         = []
        tags                = try(var.foundation.tags, {})
        # allows subnets to be defined inline - support required for scenario where
        # policy prevents creations of rules without nsg attached which isn't possible
        # for subnets managed as resources 
        use_inline_subnets = false
      },
      v,
      {
        # fixed values and internal references
        # revised way to calculate and default subnets for both inline and individual resource creation
        subnets = {
          for subnet_k, subnet_v in try(v.subnets, {}) : subnet_k => merge(
            {
              network = k
              subnet  = subnet_k
              service_endpoints = [
                "Microsoft.KeyVault",
                "Microsoft.Storage"
              ],
              delegations                                    = []
              enable_nat_gateway                             = false
              enforce_private_link_endpoint_network_policies = false
              enforce_private_link_service_network_policies  = false
              use_inline_subnets                             = try(v.use_inline_subnets, false)
            },
            subnet_v,
            {
              security_group       = try(azurerm_network_security_group.network_security_groups[subnet_v.security_group].id, null)
              resource_group_name  = try(v.resource_group_name, local.default_resource_group.name)
              virtual_network_name = k
            }
          )
        }
      }
    )
  }
}

# create virtual networks
resource "azurerm_virtual_network" "networks" {
  for_each = {
    for k, v in local.networks : k => v if !v.lookup
  }

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = each.value.tags

  # support for inline subnets were nsg attachement at point of creation is required.
  dynamic "subnet" {
    for_each = each.value.use_inline_subnets ? each.value.subnets : {}
    content {
      name           = subnet.key
      address_prefix = try(subnet.value.address_prefix, subnet.value.address_prefixes[0])
      security_group = subnet.value.security_group
    }
  }

  # add ddos reference where plan is in same subscription
  dynamic "ddos_protection_plan" {
    for_each = try(each.value.ddos_protection_plan, null) != null ? [1] : []
    content {
      id     = local.all_ddos_protection_plans[each.value.ddos_protection_plan].id
      enable = true
    }
  }

  # use explicit ddos id reference where ddos plan defined in secondary subscription
  dynamic "ddos_protection_plan" {
    for_each = try(each.value.ddos_protection_plan_id, null) != null ? [1] : []
    content {
      id     = each.value.ddos_protection_plan_id
      enable = true
    }
  }
}

# lookup virtual networks
data "azurerm_virtual_network" "networks" {
  for_each = {
    for k, v in local.networks : k => v if v.lookup
  }
  #provider = azurerm.remote
  name                = each.key
  resource_group_name = each.value.resource_group_name

  # depends on required as we may lookup an existing network
  depends_on = [azurerm_virtual_network.networks]
}

locals {
  all_networks = merge(
    azurerm_virtual_network.networks,
    data.azurerm_virtual_network.networks
  )
}

output "networks" {
  value = local.all_networks
}

# create a flattend array of subnet definition objects
# defaults are all now set at the top in local.networks
locals {
  subnets = {
    for entry in flatten(
      [
        for network_k, network_v in local.networks : [
          for subnet_k, subnet_v in network_v.subnets : subnet_v
        ]
      ]
    ) : "${entry.network}-${entry.subnet}" => entry
  }
}

# create the subnets
resource "azurerm_subnet" "networks" {
  for_each = {
    for k, v in local.subnets : k => v if !v.use_inline_subnets
  }

  resource_group_name  = local.all_resource_groups[each.value.resource_group_name].name
  virtual_network_name = each.value.virtual_network_name
  name                 = each.value.subnet
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  # To create private endpoint in a subnet, this flag should be set to true, by default it is false
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
  enforce_private_link_service_network_policies  = each.value.enforce_private_link_service_network_policies

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name
      service_delegation {
        actions = delegation.value.service_delegation.actions
        name    = delegation.value.service_delegation.name
      }
    }
  }

  depends_on = [azurerm_virtual_network.networks]
}

locals {
  # workout unique subnets we need ids for based on all the places they
  # could be cross referenced 
  subnet_lookups = distinct(
    concat(
      local.network_security_group_subnets,
      local.route_table_subnets,
      flatten(
        [
          for k, v in try(var.foundation.networks, {}) : [
            for subnet_k, subnet_v in try(v.subnets, {}) : {
              resource_group_name  = try(v.resource_group_name, local.default_resource_group.name)
              virtual_network_name = k
              subnet               = subnet_k
            }
          ]
        ]
      )
    )
  )
}

# lookup part can be moved to lookup.tf 
data "azurerm_subnet" "networks" {
  for_each = {
    for entry in local.subnet_lookups : "${entry.virtual_network_name}-${entry.subnet}" => entry
  }
  #provider = azurerm.remote
  name                 = each.value.subnet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name

  # depends on required as we may lookup existing networks
  depends_on = [azurerm_virtual_network.networks, azurerm_subnet.networks]
}

output "subnets" {
  value = data.azurerm_subnet.networks
  #value = local.legacy_subnets
}

data "azurerm_monitor_diagnostic_categories" "networks" {
  for_each = azurerm_virtual_network.networks

  resource_id = each.value.id
}

# if log analytics account or storage account have been specified for the network
# they will be used for diagnostics logging
# merge in with additional data as required 
locals {
  networks_diagnostics_settings = {
    for k, v in local.networks : k => merge(
      v,
      {
        name               = "${k}-diagnostic-setting"
        target_resource_id = azurerm_virtual_network.networks[k].id,
        logs               = data.azurerm_monitor_diagnostic_categories.networks[k].logs
        metrics            = data.azurerm_monitor_diagnostic_categories.networks[k].metrics
        enabled            = true
        retention_policy = {
          enabled = try(v.diagnostics.storage_account_name, null) != null ? true : false
          days    = try(v.diagnostics.storage_account_name, null) != null ? try(v.diagnostics.retention, 30) : null
        }
        log_analytics_workspace_id = try(azurerm_log_analytics_workspace.log_analytics[v.diagnostics.log_analytics_workspace_name].id, null)
        storage_account_id         = try(azurerm_storage_account.storage[v.diagnostics.storage_account_name].id, null)
      }
    )
    if(try(v.diagnostics, {}) != {})
  }
}

#create moniter diagnostic setting component
resource "azurerm_monitor_diagnostic_setting" "networks" {
  for_each = local.networks_diagnostics_settings

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
/*
*/