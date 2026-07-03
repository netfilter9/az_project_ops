#
# NAT Gateways
#
# This file contains all the resource definitions required to generate 
# NAT gateways 
#
# Question: Do we have this design right?  Could a single NAT gateway span
# multiple networks?
#
# Logic overview:
# * Generate a list of nat gateways to create by looking at network definitions
# * Create a public IP for each required gateway
# * Create the gateway
# * Associate the IP with the gateway
# * Assocaite the gateways with subnets within their networks where required

# create a list of nat gateways to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  nat_gateways = {
    for k, v in local.networks : k => merge(
      {
        # overrideable defaults
      },
      v,
      {
        # fixed values and internal references
        network_name = k
        gw = {
          name                    = "${k}-ngw"
          sku_name                = "Standard"
          idle_timeout_in_minutes = 10
        }
        ip = {
          name              = "${k}-ngw-pip"
          allocation_method = "Static"
          sku               = "Standard"
        }
      }
    ) if v.nat_gateway_required
  }
}

# create public ips for all the nat gatways we are going to create
resource "azurerm_public_ip" "nat_gateways" {
  for_each = local.nat_gateways

  name                = each.value.ip.name
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  allocation_method   = each.value.ip.allocation_method
  sku                 = each.value.ip.sku
}

# create nat gateways based on calculated list - one per relevant network
resource "azurerm_nat_gateway" "nat_gateways" {
  for_each = local.nat_gateways

  name                    = each.value.gw.name
  location                = each.value.location
  resource_group_name     = local.all_resource_groups[each.value.resource_group_name].name
  sku_name                = each.value.gw.sku_name
  idle_timeout_in_minutes = each.value.gw.idle_timeout_in_minutes
}

# assocaite gateway with it's IP address
resource "azurerm_nat_gateway_public_ip_association" "nat_gateways" {
  for_each = local.nat_gateways

  nat_gateway_id       = azurerm_nat_gateway.nat_gateways[each.key].id
  public_ip_address_id = azurerm_public_ip.nat_gateways[each.value.network_name].id
}

# create associations between subnets and nat gateways where required
resource "azurerm_subnet_nat_gateway_association" "nat_gateways" {
  for_each = {
    for k, v in local.subnets : k => v if v.enable_nat_gateway
  }

  subnet_id      = data.azurerm_subnet.networks[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateways[each.value.network].id
}
/*
*/