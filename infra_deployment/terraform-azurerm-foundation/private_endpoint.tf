#
# Private Endpoints
#
# This file handles the logic for adding private endpoints to Azure services that support the private endpoint feature
#
# NOTE: To access a Key Vault that has a private endpoint configured, the VNET you are trying to access the Key Vault from must be peered with the VNET that the private endpoint exists on, i.e. if resepctive VNET peering exists,
# terraform operations involving keyvault will fail after enabling a private endpoint on the keyvault. All NSG rules must be in place to ensure connectivity between the terraform client and the keyvault's private endpoint.
#
# Logic overview:
# * merge the input data with defaults to create a list of private endpoints to create
# * create them
#


# private endpoint definition
locals {
  # TODO Reserved for future service that may be using private endpoint feature
  # The idea is to move the private endpoint logic for all services that use private endpoints to this file (e.g. storage) - at that point, move this block out to the respective resource file 
  other_service_private_endpoints = flatten([])

  private_endpoints = flatten([
    for private_endpoint in concat(
      local.key_vault_private_endpoints,
      local.other_service_private_endpoints) : merge(
      {
        name = "${private_endpoint.key}-${private_endpoint.subnet_name}"
        resource_group = local.default_resource_group.name
      },
      private_endpoint,
      {
        tags = merge(
          try(var.foundation.tags, {}),
          try(private_endpoint.tags, {})
        )
    })
  ])
}

# create/mod private endpoints
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each = {
    for entry in local.private_endpoints : entry.name => entry
  }

  name                = each.value.name
  location            = try(each.value.location, local.all_resource_groups[each.value.resource_group].location)
  resource_group_name = each.value.resource_group
  subnet_id           = data.azurerm_subnet.networks["${each.value.network_name}-${each.value.subnet_name}"].id

  private_service_connection {
    name                           = each.key
    private_connection_resource_id = azurerm_key_vault.key_vault[each.value.key_vault_key].id
    subresource_names = [
      each.value.subresource_name
    ]
    is_manual_connection = false
  }

  dynamic "private_dns_zone_group" {
    for_each = try(each.value.private_dns_zone, null) != null ? [1] : []

    content {
      name = "default"

      # Private DNS Zone lookup logic won't work for cases, when a Private DNS zone is in another subscription. In such cases would need to reference it excpicitly by its id then
      private_dns_zone_ids = try(each.value.private_dns_zone.dns_zone_id, "") != "" ? [each.value.private_dns_zone.dns_zone_id] : [local.all_dns_zones[each.value.private_dns_zone.dns_zone_name].id]
    }
  }

  tags = each.value.tags

}
