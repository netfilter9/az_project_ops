#
# Load balancers
#
# This module provides a simple way to create standardised load balancers configurations.
#
# At present, we only support a very simple approach which assumes a simple 1 to 1 relationship
# beteween the front end, backend, probe and rule
#
# Each LB can have multiple "fe-be-probe-rule" groups
#

# We generate a list of all load balancers with their front end configurations
# this is a bit complex as we need to generate additional front ends for all service 
# and app combinations
# We also need to initialise some optional defaults which can be overridden as required
locals {
  lb_configs = {
    for lb_key, lb_data in try(var.deployment.load_balancers, {}) : lb_key => {
      resource_group_name = try(lb_data.resource_group_name, local.default_resource_group.name)
      location            = try(lb_data.location, local.default_resource_group.location)
      backends = flatten([
        for app_key, app_data in lb_data.backends : merge(
          {
            lb                      = lower(lb_key)
            app                     = lower(app_key)
            ip_address              = null
            probe_protocol          = "Tcp"
            interval_in_seconds     = 5
            number_of_probes        = 2
            rule_protocol           = "All"
            idle_timeout_in_minutes = 30
            enable_floating_ip      = true
            frontend_port           = 0
            backend_port            = 0
            load_distribution       = "Default"
            resource_group_name     = try(lb_data.resource_group_name, local.default_resource_group.name)
            zones                   = null
          },
          app_data,
        )
      ])
      tags = merge(
        local.tags,
        try(lb_data.tags, {})
      )
    }
  }

  # we flatten the lb_config array to work out what backends to create
  be = {
    for be in(
      flatten([
        for k, v in local.lb_configs : [
          for be_k, be_v in v.backends : be_v
        ]
      ])
    ) : "${be.lb}-${be.app}" => be
  }
}

# created load balancers with all required front ends
resource "azurerm_lb" "load_balancers" {
  for_each = local.lb_configs

  name                = each.key
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  location            = each.value.location
  sku                 = "Standard"

  # each load balancer can have multiple front ends
  dynamic "frontend_ip_configuration" {
    iterator = fe
    for_each = each.value.backends
    content {
      name      = "${fe.value.app}-fe"
      subnet_id = data.azurerm_subnet.lookups[fe.value.subnet].id
      # recommendation: ALWAYS use static
      private_ip_address_allocation = fe.value.ip_address == null ? "Dynamic" : "Static"
      private_ip_address            = fe.value.ip_address
      zones                         = fe.value.zones
    }
  }
  tags = each.value.tags
}

# create loadbalancer backend address pool
resource "azurerm_lb_backend_address_pool" "load_balancers" {
  for_each = local.be

  loadbalancer_id = azurerm_lb.load_balancers[each.value.lb].id
  name            = "${each.value.app}-bap"
}

# create loadbalancer probe
resource "azurerm_lb_probe" "load_balancers" {
  for_each = local.be

  loadbalancer_id     = azurerm_lb.load_balancers[each.value.lb].id
  name                = "${each.value.app}-probe"
  port                = each.value.probe_port
  protocol            = each.value.probe_protocol
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

# create loadbalancer rule
resource "azurerm_lb_rule" "load_balancers" {
  for_each = local.be

  loadbalancer_id                = azurerm_lb.load_balancers[each.value.lb].id
  probe_id                       = azurerm_lb_probe.load_balancers["${each.value.lb}-${each.value.app}"].id
  name                           = "${each.value.app}-rule"
  protocol                       = each.value.rule_protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "${each.value.app}-fe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.load_balancers["${each.value.lb}-${each.value.app}"].id]
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_floating_ip             = each.value.enable_floating_ip
  load_distribution              = each.value.load_distribution
}

# calculate which vms needs associating with which backends based on their groups app alignments
# we always use the first IP address to keep things simple
locals {
  bap_associations = flatten([
    for be in local.be : [
      for nicdata in local.nics : {
        ref                   = "${be.lb}-${be.app}-${nicdata.name}"
        nic_id                = azurerm_network_interface.network_interfaces[nicdata.name].id
        ip_configuration_name = azurerm_network_interface.network_interfaces[nicdata.name].ip_configuration[0].name
        lb_ref                = be.lb
        be_ref                = "${be.lb}-${be.app}"
      } if contains(nicdata.lb_refs, be.app)
    ]
  ])
}

# associate to loadbalancer backend pool if load balancer is enabled
resource "azurerm_network_interface_backend_address_pool_association" "load_balancers" {
  for_each = {
    for association in local.bap_associations : association.ref => association
  }
  network_interface_id    = each.value.nic_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.load_balancers[each.value.be_ref].id
}

#
# LB diagnostics configuration
#

# lookup diagnostic categories for each load balancer
data "azurerm_monitor_diagnostic_categories" "load_balancers" {
  for_each = {
    for k, v in azurerm_lb.load_balancers : k => v
  }
  resource_id = each.value.id
}

#create diagnostics settings for load balancer
resource "azurerm_monitor_diagnostic_setting" "load_balancers" {
  for_each = {
    for k, v in try(var.deployment.load_balancers, {})
    : k => v if lookup(lookup(v, "diagnostics", {}), "type", null) != null
  }

  name                       = "${each.key}-diagnostic-setting"
  target_resource_id         = azurerm_lb.load_balancers[each.key].id
  log_analytics_workspace_id = each.value.diagnostics.type == "log_analytics" ? data.azurerm_log_analytics_workspace.diagnostics[0].id : null
  storage_account_id         = each.value.diagnostics.type == "storage" ? data.azurerm_storage_account.diagnostics[0].id : null

  dynamic "log" {
    for_each = [for val in data.azurerm_monitor_diagnostic_categories.load_balancers[each.key].logs : val]

    content {
      category = log.value
      enabled  = true

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.diagnostics.type == "storage" ? true : false
        days    = each.value.diagnostics.type == "storage" ? lookup(each.value.diagnostics, "retention", 30) : null
      }
    }
  }

  dynamic "metric" {
    for_each = [for val in data.azurerm_monitor_diagnostic_categories.load_balancers[each.key].metrics : val]

    content {
      category = metric.value
      enabled  = true

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.diagnostics.type == "storage" ? true : false
        days    = each.value.diagnostics.type == "storage" ? lookup(each.value.diagnostics, "retention", 30) : null
      }
    }
  }
}
