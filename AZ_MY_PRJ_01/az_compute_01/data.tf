data "azurerm_resource_group" "rg" {
  name = "rg-az-stud-01"
}

# Lookup existing virtual network (optional)
data "azurerm_virtual_network" "vnet" {
  count               = var.lookup_existing_vnet ? 1 : 0
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Lookup existing subnet (optional)
data "azurerm_subnet" "subnet" {
  count              = var.lookup_existing_subnet ? 1 : 0
  name               = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
