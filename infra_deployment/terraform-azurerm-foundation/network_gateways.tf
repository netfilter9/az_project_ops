#
# Network Gateways
#
# This file defines all the resources definitions required to provison
# Network Gateways
#
# Logic Overview:
# * Generate a list of network gateways to create
# * Create a public IP for each gateway
# * Create the gateways

# create a list of network gateways to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  network_gateways = {
    for k, v in try(var.foundation.network_gateways, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
      },
      v,
      {
        # fixed values and interal references
        subnet_id = azurerm_subnet.networks["${v.network}-GatewaySubnet"].id
        ip = {
          name              = "${k}-pip"
          allocation_method = "Dynamic"
          sku               = "Basic"
        }
        ip_config = {
          name                          = "default"
          private_ip_address_allocation = "Dynamic"
        }
        type                  = "Vpn"
        vpn_type              = "RouteBased"
        active_active         = false
        enable_bgp            = false
        sku                   = "VpnGw1"
        generation            = "Generation1"
        vpn_client_protocols  = ["SSTP", "IkeV2"]
        root_certificate_name = "RootCert"

        # this is a dirty workaroud as dependency management isn't working and
        # Azure has race condition issues
        fudge = azurerm_firewall.firewalls
      }
    )
  }
}

# create ip address for vpn
resource "azurerm_public_ip" "network_gateways" {
  for_each = local.network_gateways

  name                = each.value.ip.name
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  allocation_method   = each.value.ip.allocation_method
  sku                 = each.value.ip.sku
}

# create vpn
resource "azurerm_virtual_network_gateway" "network_gateways" {
  for_each = local.network_gateways

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  type                = each.value.type
  vpn_type            = each.value.vpn_type
  active_active       = each.value.active_active
  enable_bgp          = each.value.enable_bgp
  sku                 = each.value.sku
  generation          = each.value.generation
  ip_configuration {
    name                          = each.value.ip_config.name
    public_ip_address_id          = azurerm_public_ip.network_gateways[each.key].id
    private_ip_address_allocation = each.value.ip_config.private_ip_address_allocation
    subnet_id                     = each.value.subnet_id
  }
  vpn_client_configuration {
    address_space        = each.value.client_address_space
    vpn_client_protocols = each.value.vpn_client_protocols
    root_certificate {
      name = each.value.root_certificate_name
      # TODO. Change this so it comes from a file 
      public_cert_data = each.value.public_cert_data
    }
  }
}
/*
*/