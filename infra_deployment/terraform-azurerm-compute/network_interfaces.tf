#
# Network interfaces
#
# This module supports the creation of network interfaces for all the VMs you need to provision
# if no nic configurtion is defined, we default to the creation of a single nic with a single
# dynamic IP.  Alternatively, you can specify an array of nics.  each entry in the array is
# an array of ip addresses to assign to that nic or "null" where a dynamic IP is required
#
# e.g.
# "nics" :  {
#                "name" : "nicname"
#                "subnet" : "app",
#                "ips"     : ["10.120.3.4",null]
#            },
#            {
#                "subnet" : "db",
#                "ips"     : [null]
#                "dns_servers" : []
#            }
# this would generate 2 nics.  The first nic would have a static IP and a dynamic ip, the second nic
# would have a single dynamic IP
#
# In most cases, machines should have a single static ip address

# calculate details for all the vm nics we need to create along with details of their ip address
# requirements  
# This is a little complex as we need to handle the case where no nics have been explicitly defined
#
# Note: accelerated networking is enabled by default, if your machine sku does not support it
# you will need to add "enable_accelerated_networking": false to you group config

# create the full list of nics
locals {
  nics = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in group_data.hosts : [
        for index in range(length(merge({ nics = [{}] }, host_data).nics)) : {
          hostname                      = lower(host_key)
          name                          = try(host_data.nics[index].name, "${lower(host_key)}_nic${format("%02d", index + 1)}")
          ips                           = try(host_data.nics[index].ips, [null])
          count                         = length(merge({ nics = [{}] }, host_data).nics[index])
          subnet                        = try(host_data.nics[index].subnet, group_data.subnet, "")
          dns_servers                   = try(host_data.nics[index].dns_servers, [])
          enable_accelerated_networking = try(group_data.enable_accelerated_networking, true)
          resource_group_name           = try(group_data.resource_group_name, local.default_resource_group.name)
          location                      = try(group_data.location, local.default_resource_group.location)
          lb_refs = try(
            host_data.nics[index].lb_refs,
            host_data.lb_refs,
            group_data.lb_refs,
            []
          )
          asgs = try(
            host_data.nics[index].asgs,
            host_data.asgs,
            group_data.asgs,
            []
          )
          nsg = try(
            host_data.nics[index].nsg,
            host_data.nsg,
            group_data.nsg,
            null
          )
          tags = merge(
            local.tags,
            try(group_data.tags, {}),
            try(host_data.tags, {}),
            try(host_data.nics[index].tags, {})
          )
        }
      ]
    ]
  ])
}

resource "azurerm_network_interface" "network_interfaces" {
  for_each = {
    for nic in local.nics : nic.name => nic
  }

  name                          = each.value.name
  resource_group_name           = local.all_resource_groups[each.value.resource_group_name].name
  location                      = each.value.location
  enable_accelerated_networking = each.value.enable_accelerated_networking
  dns_servers                   = each.value.dns_servers
  tags                          = each.value.tags
  #tags                          = lookup(var.deployment, "tags", {})


  dynamic "ip_configuration" {
    for_each = range(length(each.value.ips))
    content {
      name                          = "ipconfig${format("%02s", ip_configuration.value + 1)}"
      subnet_id                     = data.azurerm_subnet.lookups[each.value.subnet].id
      private_ip_address_allocation = each.value.ips[ip_configuration.value] == null ? "Dynamic" : "Static"
      primary                       = (ip_configuration.value == 0 ? true : false)
      private_ip_address            = each.value.ips[ip_configuration.value]
    }
  }
}

# associate network interfaces with ASGs
locals {
  nic_asg_associations = flatten([
    for nic in local.nics : [
      for asg in nic.asgs : {
        key     = "${nic.name}-${asg}"
        nic_key = nic.name
        asg_key = asg
      }
    ]
  ])
}

resource "azurerm_network_interface_application_security_group_association" "network_interfaces" {
  for_each = {
    for v in local.nic_asg_associations : v.key => v
  }
  network_interface_id          = azurerm_network_interface.network_interfaces[each.value.nic_key].id
  application_security_group_id = local.all_application_security_groups[each.value.asg_key].id
}

# associate network interfaces with NSGs
resource "azurerm_network_interface_security_group_association" "network_interfaces" {
  for_each = {
    for nic in local.nics : nic.name => nic if nic.nsg != null
  }
  network_interface_id      = azurerm_network_interface.network_interfaces[each.key].id
  network_security_group_id = local.all_network_security_groups[each.value.nsg].id
}
/*
*/