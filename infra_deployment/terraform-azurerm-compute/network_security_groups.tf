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
    for k, v in try(var.deployment.network_security_groups, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        # allow rule to be defined inline (supports legacy builds)
        use_inline_rules = false
        lookup           = false
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
}
# create network security groups
resource "azurerm_network_security_group" "network_security_groups" {
  for_each = {
    for k, v in local.network_security_groups : k => v if !v.lookup
  }

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

  depends_on = [
    azurerm_resource_group.resource_group
  ]
}

data "azurerm_network_security_group" "network_security_groups" {
  for_each = {
    for k, v in local.network_security_groups : k => v if v.lookup
  }
  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [
    azurerm_network_security_group.network_security_groups
  ]
}

locals {
  all_network_security_groups = merge(
    azurerm_network_security_group.network_security_groups,
    data.azurerm_network_security_group.network_security_groups
  )
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
    for group in try(each.value.destination_application_security_groups, []) : local.all_application_security_groups[group].id
  ]

  source_application_security_group_ids = each.value.source_application_security_groups == null ? null : [
    for group in try(each.value.source_application_security_groups, []) : local.all_application_security_groups[group].id
  ]

  description = each.value.description

  depends_on = [azurerm_network_security_group.network_security_groups, azurerm_application_security_group.application_security_groups]
}

/*
*/