#
# Route Tables
#
# This file contains all the resource definitions you need to support
# the creation of route tables
#
# Logic Overview:
# * Generate a list of route tables to create (including inline routes)
# * Create them
# * Generate a list of routes to create as independent resources 
# * Create them
# * Generate a list of route table association to tie them to subnets
# * Create them

# create a list of route tables to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  route_tables = {
    for k, v in try(var.foundation.route_tables, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        # allow routes to be defined inline rather than as individual resources
        # included for legacy support
        use_inline_routes = false
        tags              = try(var.foundation.tags, {})
      },
      v,
      {
        # fixed values and internal references
        disable_bgp_route_propagation = false

        # update routes with defaults
        routes = {
          for route_k, route_v in try(v.routes, []) : route_k => merge(
            {
              next_hop_type          = try(v.next_hop_type, "VirtualNetworkGateway")
              next_hop_in_ip_address = null
            },
            route_v
          )
        }
      }
    )
  }

  # calculate the list of subnets used by the routes - this will be used in the networks.tf
  # file to lookup subnet ids
  route_table_subnets = flatten(
    [
      for k, v in try(var.foundation.route_tables, {}) : [
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

# create required route tables
resource "azurerm_route_table" "route_tables" {
  for_each = local.route_tables

  name                          = each.key
  location                      = each.value.location
  resource_group_name           = local.all_resource_groups[each.value.resource_group_name].name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation

  dynamic "route" {
    for_each = each.value.use_inline_routes ? each.value.routes : {}
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = each.value.tags
  # avoids race conditions in Azure
  depends_on = [azurerm_subnet_nat_gateway_association.nat_gateways]
}

# create a flattened array of all the routes we need to create 
locals {
  routes = flatten(
    [
      for k, v in try(local.route_tables, {}) : [
        for route_k, route_v in v.routes : merge(
          {
            resource_group_name    = v.resource_group_name
            route_table_name       = k
            name                   = route_k
            next_hop_in_ip_address = null
          },
          route_v,
          {
            key = "${k}=${route_k}"
          }
        )
      ] if !v.use_inline_routes
    ]
  )
}

# create the individual routes as required
resource "azurerm_route" "route_tables" {
  for_each = {
    for route in local.routes : route.key => route
  }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  route_table_name    = each.value.route_table_name
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type
  next_hop_in_ip_address =  each.value.next_hop_in_ip_address

  #try to associate directly the private ip from the firewall in the route. private ip could not be found so far in vwan context (-> will evaluate null). Further work needed

  # next_hop_in_ip_address = try(
  #   each.value.next_hop_in_ip_address,
  #   local.all_firewalls[each.value.firewall_association].ip_configuration.private_ip_address, #.virtual_hub[0].private_ip_address, 
  #   null
  # )  

  depends_on = [azurerm_route_table.route_tables]
}

# calculate route table association data if we have any
locals {
  subnet_route_table_associations = {
    for entry in flatten([
      for k, v in local.route_tables : [
        for subnet_association in try(v.subnet_associations, []) : [
          for subnet in subnet_association.subnets : {
            key            = "${subnet_association.network}-${subnet}"
            subnet_id      = data.azurerm_subnet.networks["${subnet_association.network}-${subnet}"].id
            route_table_id = azurerm_route_table.route_tables[k].id
          }
        ]
      ]
    ]) : entry.key => entry
  }
}

# create the associations
resource "azurerm_subnet_route_table_association" "route_tables" {
  for_each = local.subnet_route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
/*
*/
