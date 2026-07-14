data "azurerm_resource_group" "rg" {
  name = "rg-az-stud-01"
}
# Look up the existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = "vnet-stud-01"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Look up the existing Subnet inside that VNet
data "azurerm_subnet" "subnet" {
  name                 = "snet-stud-01"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}