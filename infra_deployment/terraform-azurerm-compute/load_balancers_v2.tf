#
# Load Balancers V2
#
# This file provides a more complete implementation of the load balancer
# capabilties offered by Azure. The trade off is seen in the more complex
# input file format
#
# Logic flow
# * Calculate an array of the load balancers that we need
# * Calculate an array of any puplic ips required for the front ends 
# * Create the public ips
# * Create the load balancers with their front ends
# * Calculate an array of backends for the load balancers
# * Create the backends
# * Calculate an array of the probes required
# * Create the probes
# * Calculate an array of the rules required
# * Create the rules
# * Calculate an array of the outbound rules required
# * Create the rules
# * Calculate an array of the backend address pool associations required
# * Create the associations

locals {
  load_balancers_v2 = {
    for k, v in try(var.deployment.load_balancers_v2, {}) : k => merge(
      {
        # use defaults - these can be overridden in "v" as required
        resource_group_name = local.default_resource_group.name
        location            = local.default_resource_group.location
        sku                 = "Standard"
      },
      v,
      {
        # merge tags as required
        tags = merge(
          local.tags,
          try(v.tags, {})
        )
      }
    )
  }

  # calculate public ips as required
  load_balancers_v2_public_ips = flatten(
    [
      for k, v in local.load_balancers_v2 : [
        for fe_k, fe_v in try(v.front_end_ips, {}) : merge(
          {
            key                 = "${k}-${fe_k}"
            name                = fe_k
            resource_group_name = v.resource_group_name
            location            = v.location
            allocation_method   = "Static"
            tags                = v.tags
            sku                 = v.sku
          },
          fe_v,
          {}
        ) if try(fe_v.use_public_ip, false)
      ]
    ]
  )
}

# create public ips as required
resource "azurerm_public_ip" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_public_ips : v.key => v
  }

  name                    = each.key
  location                = each.value.location
  resource_group_name     = each.value.resource_group_name
  allocation_method       = each.value.allocation_method
  sku                     = try(each.value.sku, null)
  sku_tier                = try(each.value.sku_tier, null)
  zones                   = try(each.value.zones, null)
  ip_version              = try(each.value.ip_version, null)
  idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, null)
  domain_name_label       = try(each.value.domain_name_label, null)
  reverse_fqdn            = try(each.value.reverse_fqdn, null)
  public_ip_prefix_id     = try(each.value.public_ip_prefix_id, null)
  ip_tags                 = try(each.value.ip_tags, null)
  tags                    = each.value.tags
}

# create the lod balancers
resource "azurerm_lb" "load_balancers_v2" {
  for_each = local.load_balancers_v2

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  sku                 = each.value.sku

  # handle front end configurations (public and private)
  dynamic "frontend_ip_configuration" {
    for_each = try(each.value.front_end_ips, [])

    content {
      name  = frontend_ip_configuration.key
      zones = try(frontend_ip_configuration.value.zones, null)
      subnet_id = try(
        data.azurerm_subnet.lookups[frontend_ip_configuration.value.subnet].id,
        null
      )
      private_ip_address            = try(frontend_ip_configuration.value.private_ip_address, null)
      private_ip_address_allocation = try(frontend_ip_configuration.value.private_ip_address_allocation, null)
      private_ip_address_version    = try(frontend_ip_configuration.value.private_ip_address_version, null)
      public_ip_address_id = try(
        frontend_ip_configuration.value.use_public_ip,
        false
      ) ? azurerm_public_ip.load_balancers_v2["${each.key}-${frontend_ip_configuration.key}"].id : null
      public_ip_prefix_id = try(
        frontend_ip_configuration.value.use_public_ip,
        false
      ) ? try(frontend_ip_configuration.value.public_ip_prefix_id, null) : null
    }
  }

  tags = each.value.tags
}

# calculate the backend address pools
locals {
  load_balancers_v2_backend_address_pools = flatten(
    [
      for k, v in local.load_balancers_v2 : [
        for be in try(v.backend_address_pools, []) : {
          key           = "${k}-${be}"
          load_balancer = k
          name          = be
        }
      ]
    ]
  )
}

# create loadbalancer backend address pools
resource "azurerm_lb_backend_address_pool" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_backend_address_pools : v.key => v
  }

  loadbalancer_id = azurerm_lb.load_balancers_v2[each.value.load_balancer].id
  name            = each.value.name
}

# calculate the probes
locals {
  load_balancers_v2_probes = flatten(
    [
      for k, v in local.load_balancers_v2 : [
        for probe_k, probe_v in try(v.probes, {}) : merge(
          {
            key                 = "${k}-${probe_k}"
            name                = probe_k
            resource_group_name = v.resource_group_name
            load_balancer       = k
          },
          probe_v,
          {}
        )
      ]
    ]
  )
}

# create the probes
resource "azurerm_lb_probe" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_probes : v.key => v
  }

  name                = each.value.name
  loadbalancer_id     = azurerm_lb.load_balancers_v2[each.value.load_balancer].id
  protocol            = try(each.value.protocol, null)
  port                = each.value.port
  request_path        = try(each.value.request_path, null)
  interval_in_seconds = try(each.value.interval_in_seconds, null)
  number_of_probes    = try(each.value.number_of_probes, null)
}

# calculate the rules
locals {
  load_balancers_v2_rules = flatten(
    [
      for k, v in local.load_balancers_v2 : [
        for rule_k, rule_v in try(v.rules, {}) : merge(
          {
            key                 = "${k}-${rule_k}"
            name                = rule_k
            resource_group_name = v.resource_group_name
            load_balancer       = k
          },
          rule_v,
          {}
        )
      ]
    ]
  )
}

# create the rules
resource "azurerm_lb_rule" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_rules : v.key => v
  }

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.load_balancers_v2[each.value.load_balancer].id
  frontend_ip_configuration_name = each.value.front_end_ip
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids = [try(
    azurerm_lb_backend_address_pool.load_balancers_v2["${each.value.load_balancer}-${each.value.backend_address_pool}"].id,
    null
  )]
  probe_id = try(
    azurerm_lb_probe.load_balancers_v2["${each.value.load_balancer}-${each.value.probe}"].id,
    null
  )
  enable_floating_ip      = try(each.value.enable_floating_ip, null)
  idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, null)
  load_distribution       = try(each.value.load_distribution, null)
  disable_outbound_snat   = try(each.value.disable_outbound_snat, null)
  enable_tcp_reset        = try(each.value.enable_tcp_reset, null)
}

# calcualte the outbound rules
locals {
  load_balancers_v2_outbound_rules = flatten(
    [
      for k, v in local.load_balancers_v2 : [
        for outbound_rule_k, outbound_rule_v in try(v.outbound_rules, {}) : merge(
          {
            key                 = "${k}-${outbound_rule_k}"
            name                = outbound_rule_k
            resource_group_name = v.resource_group_name
            load_balancer       = k
          },
          outbound_rule_v,
          {}
        )
      ]
    ]
  )
}

# create the outbound rules
resource "azurerm_lb_outbound_rule" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_outbound_rules : v.key => v
  }

  name            = each.value.name
  loadbalancer_id = azurerm_lb.load_balancers_v2[each.value.load_balancer].id

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ips
    content {
      name = frontend_ip_configuration.value
    }
  }

  backend_address_pool_id = try(
    azurerm_lb_backend_address_pool.load_balancers_v2["${each.value.load_balancer}-${each.value.backend_address_pool}"].id,
    null
  )
  protocol                 = each.value.protocol
  enable_tcp_reset         = try(each.value.enable_tcp_reset, null)
  allocated_outbound_ports = try(each.value.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = try(each.value.idle_timeout_in_minutes, null)
}

# calculate the backend address pool associations
locals {
  load_balancers_v2_outbound_bap_associations = flatten(
    [
      for be in local.load_balancers_v2_backend_address_pools : [
        for nicdata in local.nics : {
          key                   = "${be.key}-${nicdata.name}"
          nic_id                = azurerm_network_interface.network_interfaces[nicdata.name].id
          ip_configuration_name = azurerm_network_interface.network_interfaces[nicdata.name].ip_configuration[0].name
          lb_ref                = be.load_balancer
          be_ref                = be.key
        } if contains(nicdata.lb_refs, be.key)
      ]
    ]
  )
}

# create the associations
resource "azurerm_network_interface_backend_address_pool_association" "load_balancers_v2" {
  for_each = {
    for v in local.load_balancers_v2_outbound_bap_associations : v.key => v
  }
  network_interface_id    = each.value.nic_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.load_balancers_v2[each.value.be_ref].id
}