#
# Firewalls
#
# This file contains all the resources required in order to provison
# firewalls 
#
# Logic overview: 
# * Generate a list of firewalls to create
# * Create a public IP for them
# * Create the firewall
# * Generate a list of application rules to assign to firewall
# * Create them
# * Generate a list of NAT rules to assign to the firewall
# * Create them
# * Generate a list of network rules to assign to the firewall
# * Create them 

# create a list of firewalls to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  # handle optional parameters for firewalls
  firewalls = {
    for k, v in try(var.foundation.firewalls, {}) : k => merge(
      {
        # overrideable defaults
        lookup                       = false
        application_rule_collections = {}
        nat_rule_collections         = {}
        network_rule_collections     = {}
        location                     = local.default_resource_group.location
        resource_group_name          = local.default_resource_group.name
        tags                         = try(var.foundation.tags, {})
        zones                        = null
        virtual_hub                  = try("${v.virtual_wan.name}-${v.virtual_wan.hub}", null)
        sku_name                     = "AZFW_Hub"
        sku_tier                     = "Premium"
      },
      v,
      try(v.lookup, false) == true ? {} : {
        # internal references and fixed values
        subnet_id         = try(azurerm_subnet.networks["${v.network}-AzureFirewallSubnet"].id, null)
        nic_name          = "${k}-fw-pip"
        ip_config_name    = "${k}-AzureFirewallSubnet"
        allocation_method = "Static"
        sku               = "Standard"
      }
    )
  }
}

# create public ip address for each firewall
resource "azurerm_public_ip" "firewalls" {
  for_each = {
    for k, v in local.firewalls : k => v if !v.lookup && v.virtual_hub == null
  }

  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  tags                = each.value.tags
  zones               = each.value.zones
}

# create each firewall
resource "azurerm_firewall" "firewalls" {
  for_each = {
    for k, v in local.firewalls : k => v if !v.lookup
  }

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  tags                = each.value.tags
  sku_name            = each.value.sku_name
  sku_tier            = each.value.sku_tier
  firewall_policy_id = try(
    each.value.firewall_policy_id,
    local.firewall_policies_all[each.value.firewall_policy_name].id,
    null
  )
  zones = try(each.value.zones,[])

  dynamic "ip_configuration" {

    for_each = each.value.virtual_hub == null ? [1] : [] #if virtual hub is null, take 1 ip config, otherwise nothing
    content {
      name                 = each.value.ip_config_name
      subnet_id            = each.value.subnet_id
      public_ip_address_id = azurerm_public_ip.firewalls[each.key].id
    }
  }

  dynamic "virtual_hub" {

    for_each = each.value.virtual_hub != null ? [1] : [] #if virtual hub is not null, take 1 virtual hub reference
    content {
      virtual_hub_id = azurerm_virtual_hub.virtual_wans[each.value.virtual_hub].id
    }
  }

  # avoids race condition in Azure provisioning
  depends_on = [azurerm_subnet_route_table_association.route_tables]
}

# Data block for lookup firewalls
data "azurerm_firewall" "firewalls" {
  for_each = {
    for k, v in local.firewalls : k => v if v.lookup
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_firewall.firewalls]
}

locals {
  all_firewalls = merge(
    azurerm_firewall.firewalls,
    data.azurerm_firewall.firewalls
  )
}

# Local block for Application rules
# each firewall may or may not have an application rules collection block
locals {
  application_rules = {
    for entry in flatten([
      for k, v in local.firewalls : [
        for collection_k, collection_v in v.application_rule_collections : [
          merge(
            {
              name                = collection_k
              azure_firewall_name = local.all_firewalls[k].name
            },
            v,
            collection_v
          )
        ]
      ]
    ]) : "${entry.azure_firewall_name}-${entry.name}" => entry
  }
}


#this block is for creation of application rule
resource "azurerm_firewall_application_rule_collection" "firewalls" {
  for_each = local.application_rules

  name                = each.key
  azure_firewall_name = each.value.azure_firewall_name
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  priority            = each.value.priority
  action              = each.value.action
  dynamic "rule" {
    for_each = each.value.rules
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses
      target_fqdns     = rule.value.target_fqdns
      protocol {
        port = rule.value.protocol.port
        type = rule.value.protocol.type
      }
    }
  }
}

# Local block for NAT rules
# each firewall may or may not have a NAT rules collection block
locals {
  nat_rules = { for entry in flatten([
    for k, v in local.firewalls : [
      for collection_k, collection_v in v.nat_rule_collections : [
        merge(
          {
            name                = collection_k
            azure_firewall_name = local.all_firewalls[k].name
          },
          v,
          collection_v
        )
      ]
    ]
    ]) : "${entry.azure_firewall_name}-${entry.name}" => entry
  }
}

#this Block is for creation of nat rules
resource "azurerm_firewall_nat_rule_collection" "firewalls" {
  for_each = local.nat_rules

  name                = each.value.name
  azure_firewall_name = each.value.azure_firewall_name
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  priority            = each.value.priority
  action              = each.value.action
  dynamic "rule" {
    for_each = each.value.rules
    content {
      name              = rule.value.name
      source_addresses  = rule.value.source_addresses
      destination_ports = rule.value.destination_ports
      #TODO I don't understand this
      destination_addresses = [azurerm_public_ip.firewalls[each.value.azure_firewall_name].ip_address]
      translated_port       = rule.value.translated_port
      translated_address    = rule.value.translated_address
      protocols             = rule.value.protocols
    }
  }
}

# Local block for network rules
# each firewall may or may not have a network rules collection block
locals {
  network_rules = {
    for entry in flatten([
      for k, v in local.firewalls : [
        for collection_k, collection_v in v.network_rule_collections : [
          merge(
            {
              name                = collection_k
              azure_firewall_name = local.all_firewalls[k].name
            },
            v,
            collection_v
          )
        ]
      ]
    ]) : "${entry.azure_firewall_name}-${entry.name}" => entry
  }
}

#this block is for creation of Network Rule
resource "azurerm_firewall_network_rule_collection" "firewalls" {
  for_each = local.network_rules

  name                = each.value.name
  azure_firewall_name = each.value.azure_firewall_name
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  priority            = each.value.priority
  action              = each.value.action
  dynamic "rule" {
    for_each = each.value.rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_ports     = rule.value.destination_ports
      destination_addresses = rule.value.destination_addresses
      protocols             = rule.value.protocols
    }
  }
}
/*
*/
