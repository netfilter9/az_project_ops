#
# Azure Bastion
#
# This file handles the creation of Azure bastions
#
# Logic overview:
# * Generate a list of Azure Bastions to create
# * Create required Azure Bastions

# create a list of Azure Bastions to create by combining
# defaults, inputs, fixed values and internal references 
locals {
  bastions = {
    for k, v in try(var.foundation.azure_bastions, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        public_ip_name = null
      },
      v,
      {
        # internal references and fixed values
        subnet_id         = data.azurerm_subnet.networks["${v.network}-AzureBastionSubnet"].id
        nic_name          = "${k}-azure-bastion-pip"
        ip_config_name    = "${k}-AzureBastionSubnet"
        allocation_method = "Static"
        sku               = "Standard"
      }
    )
  }
}

resource "azurerm_public_ip" "azure_bastions" {
  for_each = {
    for k,v in local.bastions : k => v if v.public_ip_name == null
  }

  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}

data "azurerm_public_ip" "azure_bastions" {
  for_each = {
    for k,v in local.bastions : k => v if v.public_ip_name != null
  }
  name = each.value.public_ip_name
  resource_group_name = local.default_resource_group.name
  
}

resource "azurerm_bastion_host" "azure_bastions" {

  for_each = local.bastions

  name                = each.key
  location            = local.all_resource_groups[each.value.resource_group_name].location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name

  ip_configuration {
    name                 = each.value.ip_config_name
    subnet_id            = each.value.subnet_id
    #public_ip_address_id = azurerm_public_ip.azure_bastions[each.key].id
    public_ip_address_id = data.azurerm_public_ip.azure_bastions[each.key].id
  }

}