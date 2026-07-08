output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "public_ip_address" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

//output "vnet_id" {
  //description = "The ID of the virtual network"
  //value       = local.vnet_id
//}

//output "subnet_id" {
  //description = "The ID of the subnet"
  //value       = local.subnet_id
//}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.nic.id
}

//output "nsg_id" {
//  description = "The ID of the network security group"
//  value       = azurerm_network_security_group.nsg.id
//}

output "resource_group_name" {
  description = "The resource group name"
  value       = data.azurerm_resource_group.rg.name
}
