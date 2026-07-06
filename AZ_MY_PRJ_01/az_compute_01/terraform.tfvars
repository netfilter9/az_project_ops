# Virtual Network
lookup_existing_vnet = false
vnet_name            = "vnet-az-compute-01"
address_space        = ["10.0.0.0/16"]

# Subnet
lookup_existing_subnet = false
subnet_name            = "subnet-compute-01"
subnet_address_prefixes = ["10.0.1.0/24"]

# Network Interface
nic_name = "nic-vm-01"

# Public IP
public_ip_name = "pip-vm-01"

# Network Security Group
nsg_name = "nsg-vm-01"

# Virtual Machine
vm_name            = "vm-compute-01"
vm_size            = "Standard_B2s"
admin_username     = "azureuser"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

# OS Disk
os_disk_type = "Premium_LRS"

# Image (Ubuntu 22.04 LTS)
image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-jammy"
image_sku       = "22_04-lts-gen2"
image_version   = "Latest"

# Tags
tags = {
  environment = "development"
  project     = "az-compute"
  owner       = "devops"
}
