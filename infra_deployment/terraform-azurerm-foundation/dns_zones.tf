#
# DNS Zones
#
# This file contains all the resources required in order to provision
# DNS zones
#
# WARNING: This functionality requires a design review. Should this
# be a subcomponent of a vnet?  or can the zone span vnets?
#
# Logic:
# * Create a list of DNS Zones to create
# * Create them
# * Create a list of required DNS Zone to network links
# * Create them 

# create a list of dns zones to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  dns_zones = {
    for k, v in try(var.foundation.dns_zones, {}) : k => merge(
      {
        # overrideable defaults
        #TODO workout if this should be a single value rather than an array
        virtual_networks    = []
        resource_group_name = local.default_resource_group.name
        lookup              = false
      },
      v,
      {
        # internal references and fixed values
      }
    )
  }
}

# create private dns zones where required
resource "azurerm_private_dns_zone" "dns_zones" {
  for_each = {
    for k, v in local.dns_zones : k => v if !v.lookup
  }

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
}

data "azurerm_private_dns_zone" "dns_zones" {
  for_each = {
    for k, v in local.dns_zones : k => v if v.lookup
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_private_dns_zone.dns_zones]
}

locals {
  all_dns_zones = merge(
    azurerm_private_dns_zone.dns_zones,
    data.azurerm_private_dns_zone.dns_zones
  )
}

locals {
  dns_zone_links = {
    for entry in flatten([
      for zone_k, zone_v in local.dns_zones : [
        for vnet_k, vnet_v in try(zone_v.virtual_networks, {}) : merge(
          {
            name                 = "${zone_k}-${vnet_k}"
            vnet_name            = vnet_k
            registration_enabled = true
            resource_group_name  = local.all_dns_zones[zone_k].resource_group_name
          },
          vnet_v,
          {
            # these references ensure correct dependency mapping in terraform
            private_dns_zone_name = local.all_dns_zones[zone_k].name
            virtual_network_id    = local.all_networks[vnet_k].id
          }
        )
      ]
    ]) : entry.name => entry
  }
}

# associated zones with networks
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zones" {
  for_each = local.dns_zone_links

  name                  = each.key
  resource_group_name   = local.all_resource_groups[each.value.resource_group_name].name
  private_dns_zone_name = each.value.private_dns_zone_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
}

output "dns_zones" {
  value = local.dns_zones
}

output "dns_zone_links" {
  value = local.dns_zone_links
}

/*
*/