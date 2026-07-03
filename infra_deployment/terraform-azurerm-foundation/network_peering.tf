#
# Network Peering
#
# This file contains all the resources definitions required to provision 
# network peerings 
#
# Logic Overview:
# * Generate a list of peerings to create (including bidirectional peering when required)
# * Calculate a distinct list of vnets and look them up (useful when deploying peerings
#   separately from network creation)
# * Lookup all required local vnet references
# * Lookup all required remote vnet references
# * Create peerings relating to local network
# * Create peerings relating to remote network

# create a list of network peerings to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  peerings = concat(
    [
      # create main A to B peering
      for peering in try(var.foundation.network_peerings, {}) : merge(
        {
          # defaults just in case inputs are missing
          allow_virtual_network_access = true
          allow_forwarded_traffic      = false
          allow_gateway_transit        = false

        },
        peering,
        {
          # update peerings with additional defaults if required
          A = merge(
            {
              remote              = false
              resource_group_name = local.default_resource_group.name
            },
            peering.A
          )
          B = merge(
            {
              remote              = false
              resource_group_name = local.default_resource_group.name
            },
            peering.B
          )
        },
        {
          # generate a unique key for each peering based on the various valid options
          # this simpler than it looks - first match wins
          key = try(peering.key,
            "${peering.A.resource_group_name}-${peering.A.vnet}-to-${peering.B.resource_group_name}-${peering.B.vnet}",
            "${local.default_resource_group.name}-${peering.A.vnet}-to-${peering.B.resource_group_name}-${peering.B.vnet}",
            "${peering.A.resource_group_name}-${peering.A.vnet}-to-${local.default_resource_group.name}-${peering.B.vnet}",
            "${local.default_resource_group.name}-${peering.A.vnet}-to-${local.default_resource_group.name}-${peering.B.vnet}"
          )
        }
      )
    ],
    [
      # generate B to A peerings if bidirectional is true
      for peering in try(var.foundation.network_peerings, {}) : merge(
        {
          allow_virtual_network_access = true
          allow_forwarded_traffic      = false
          allow_gateway_transit        = false
        },
        peering,
        {
          #swithc over vnets for bi-directional peering
          B = merge(
            {
              remote              = false
              resource_group_name = local.default_resource_group.name
            },
            peering.A
          )
          A = merge(
            {
              remote              = false
              resource_group_name = local.default_resource_group.name
            },
            peering.B
          )
        },
        {
          key = try("${peering.key}-reverse",
            "${peering.B.resource_group_name}-${peering.B.vnet}-to-${peering.A.resource_group_name}-${peering.A.vnet}",
            "${local.default_resource_group.name}-${peering.B.vnet}-to-${peering.A.resource_group_name}-${peering.A.vnet}",
            "${peering.B.resource_group_name}-${peering.B.vnet}-to-${local.default_resource_group.name}-${peering.A.vnet}",
            "${local.default_resource_group.name}-${peering.B.vnet}-to-${local.default_resource_group.name}-${peering.A.vnet}"
          )
        }
      ) if try(peering.bidirectional, false)
    ]
  )

  # generate unique list of local and remote networks
  vnets = distinct(
    flatten(
      concat(
        [
          for peering in local.peerings :
          peering.A
        ],
        [
          for peering in local.peerings :
          peering.B
        ]
      )
    )
  )
}

# lookup networks in local subscription
data "azurerm_virtual_network" "network_peering_local" {
  for_each = {
    for vnet in local.vnets : vnet.vnet => vnet if !vnet.remote
  }
  name                = each.value.vnet
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name

  # depends on required as we may need to create these networks first
  depends_on = [local.all_networks]
}

# lookup networks in remote subscription
data "azurerm_virtual_network" "network_peering_remote" {
  for_each = {
    for entry in local.vnets : entry.vnet => entry if entry.remote
  }
  provider            = azurerm.remote
  name                = each.value.vnet
  resource_group_name = each.value.resource_group_name

  # depends on required as we may need to create these networks first
  depends_on = [local.all_networks]
}

# generate peerings in local subscription
resource "azurerm_virtual_network_peering" "network_peering_local" {
  for_each = {
    for peering in local.peerings : peering.key => peering if peering.A.remote == false
  }

  name                 = each.key
  resource_group_name  = local.all_resource_groups[each.value.A.resource_group_name].name
  virtual_network_name = each.value.A.vnet
  remote_virtual_network_id = (
    each.value.B.remote == true ?
    data.azurerm_virtual_network.network_peering_remote[each.value.B.vnet].id :
    data.azurerm_virtual_network.network_peering_local[each.value.B.vnet].id
  )
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  # `allow_gateway_transit` must be set to false for Global vnet Peering
  allow_gateway_transit = each.value.allow_gateway_transit

  # avoids race condition in Azure provisioning
  depends_on = [azurerm_firewall.firewalls]
}

# generate peerings in remote subscription
resource "azurerm_virtual_network_peering" "network_peering_remote" {
  for_each = {
    for peering in local.peerings : peering.key => peering if peering.A.remote == true
  }

  provider             = azurerm.remote
  name                 = each.key
  resource_group_name  = each.value.A.resource_group_name
  virtual_network_name = each.value.A.vnet
  remote_virtual_network_id = (
    each.value.B.remote == true ?
    data.azurerm_virtual_network.network_peering_remote[each.value.B.vnet].id :
    data.azurerm_virtual_network.network_peering_local[each.value.B.vnet].id
  )
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  # `allow_gateway_transit` must be set to false for Global vnet Peering
  allow_gateway_transit = each.value.allow_gateway_transit

  # avoids race condition in Azure provisioning
  depends_on = [azurerm_virtual_network_peering.network_peering_local]
}
/*
*/
