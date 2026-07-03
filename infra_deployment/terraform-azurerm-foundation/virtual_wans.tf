#
# Virtual WANs
#
# This file contains all the resource definitions required to 
# provision virtual WANs
#
# TODO: We need a design for this so we can review and correct
#
# Logic Overview:
# * Generate a list of Virtual WANS to create
# * Create them
# * Generate a list of Virtual Hubs to create for each Virtual WAN
# * Create them
# * If the hub definitions include a vpn gateway - create it
# * If the hub definitions include an express route gateway - create it
# * If the hub definitions include a point to site VPN gateway
#   * Create a vpn server configuration for it
#   * Create the point to site VPN gateway
# * Calculate a list of virtual hub connections
# * Create them

# create a list of virtual wans to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  virtual_wans = {
    for k, v in try(var.foundation.virtual_wans, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
      },
      v,
      {
        # fixed values and internal references
      }
    )
  }
}

# create virtual wans
resource "azurerm_virtual_wan" "virtual_wans" {
  for_each = local.virtual_wans

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
}

# calculate a list of all the hubs if required and set defaults
locals {
  hubs = {
    for entry in flatten([
      for k, v in local.virtual_wans : [
        for hub_k, hub_v in try(v.hubs, {}) :
        merge(
          v,
          {
            key                   = "${k}-${hub_k}"
            vwan_key              = k
            site_to_site_gateway  = null
            point_to_site_gateway = null
            express_route_gateway = null
            routes                = []
          },
          hub_v,
          {
            virtual_wan_id = azurerm_virtual_wan.virtual_wans[k].id
          }
        )
      ]
    ]) : entry.key => entry
  }
}

# create all the virtual hubs
resource "azurerm_virtual_hub" "virtual_wans" {
  for_each = local.hubs

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  virtual_wan_id      = each.value.virtual_wan_id
  address_prefix      = each.value.address_prefix

  dynamic "route" {
    for_each = each.value.routes
    content {
      address_prefixes    = route.value.address_prefixes
      next_hop_ip_address = route.value.next_hop_ip_address
    }
  }
}

# included to avoid issues with race condition
# azure declares resources as ready before they are...

resource "time_sleep" "virtual_wans" {
  count      = length(local.virtual_wans) == 0 ? 0 : 1
  depends_on = [azurerm_virtual_hub.virtual_wans]

  create_duration = "60s"
}

# create all the site to site gateways
resource "azurerm_vpn_gateway" "virtual_wans" {
  for_each = {
    for k, v in local.hubs : k => v if try(v.vpn_gateway, null) != null
  }

  name                = "${each.key}-site-gtw"
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.virtual_wans[each.key].id
  scale_unit          = each.value.vpn_gateway.scale_unit

  # included to avoid issues with race condition
  depends_on = [time_sleep.virtual_wans]
}

# create all the express route gateways
resource "azurerm_express_route_gateway" "virtual_wans" {
  for_each = {
    for k, v in local.hubs : k => v if try(v.express_route_gateway, null) != null
  }

  name                = "${each.key}-exp-gtw"
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.virtual_wans[each.key].id
  scale_units         = each.value.express_route_gateway.scale_unit

  # included to avoid issues with race condition
  depends_on = [azurerm_vpn_gateway.virtual_wans]
}

# create vpn configs for point to site gateways
resource "azurerm_vpn_server_configuration" "virtual_wans" {
  for_each = {
    for k, v in local.hubs : k => v if try(v.point_to_site_vpn_gateway, null) != null
  }

  name                     = "${each.key}-point-gtw-config"
  resource_group_name      = local.all_resource_groups[each.value.resource_group_name].name
  location                 = each.value.location
  vpn_protocols            = ["OpenVPN", "IkeV2"]
  vpn_authentication_types = ["Certificate"]

  client_root_certificate {
    name             = "RootCert"
    public_cert_data = each.value.point_to_site_vpn_gateway.public_cert_data
  }

  # included to avoid issues with race condition
  depends_on = [azurerm_express_route_gateway.virtual_wans]
}

# create all the point to site gateways
resource "azurerm_point_to_site_vpn_gateway" "virtual_wans" {
  for_each = {
    for k, v in local.hubs : k => v if try(v.point_to_site_vpn_gateway, null) != null
  }
  name                        = "${each.key}-point-gtw"
  resource_group_name         = local.all_resource_groups[each.value.resource_group_name].name
  location                    = each.value.location
  virtual_hub_id              = azurerm_virtual_hub.virtual_wans[each.key].id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.virtual_wans[each.key].id
  scale_unit                  = each.value.point_to_site_vpn_gateway.scale_unit

  connection_configuration {
    name = "GatewayConfig"
    vpn_client_address_pool {
      address_prefixes = each.value.point_to_site_vpn_gateway.client_address_prefix
    }
  }

  # included to avoid issues with race condition
  depends_on = [azurerm_vpn_server_configuration.virtual_wans]
}

# calculate a list of all the virtual network to hub connections if required
locals {
  virtual_hub_connections = {
    for entry in flatten([
      for vwan_k, vwan_v in local.virtual_wans : [
        for hub_k, hub_v in try(vwan_v.hubs, {}) : [
          for network_k, network_v in try(hub_v.virtual_hub_connections, {}) : merge(
            {
              internet_security_enabled = true
            },
            network_v,
            {
              name                      = "${vwan_k}-${hub_k}-${network_k}-conn"
              virtual_hub_id            = azurerm_virtual_hub.virtual_wans["${vwan_k}-${hub_k}"].id
              remote_virtual_network_id = local.all_networks[network_k].id
            }
          )
        ]
      ]
    ]) : entry.name => entry
  }
}

# Connect all the virtual networks to the corresponding hubs
resource "azurerm_virtual_hub_connection" "virtual_wans" {
  for_each = local.virtual_hub_connections

  name                      = each.key
  virtual_hub_id            = each.value.virtual_hub_id
  remote_virtual_network_id = each.value.remote_virtual_network_id
  internet_security_enabled = each.value.internet_security_enabled

  # included to avoid issues with race condition
  depends_on = [azurerm_point_to_site_vpn_gateway.virtual_wans]
}
/*
*/
