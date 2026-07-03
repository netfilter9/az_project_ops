#
# Traffic Manager
#
# This file contains all the resources definitions required to provision
# Traffic manager profiles and associated end points
#
# Logic overview:
# * create a list profiles
# * create them 
# * create a list of associated end points
# * Create them

locals {
  traffic_manager_profiles = {
    for k, v in try(var.foundation.traffic_manager_profiles, {}) : k => merge(
      {
        resource_group_name  = local.default_resource_group.name
        profile_status       = "Enabled"
        max_return           = null
        tags                 = try(var.foundation.tags, {})
        traffic_view_enabled = false
      },
      v,
      {
        dns_config = merge(
          {
            ttl = 60
          },
          v.dns_config
        )
        monitor_config = merge(
          {
            path                         = null
            expected_status_code_ranges  = []
            custom_headers               = []
            interval_in_seconds          = 30
            timeout_in_seconds           = 10
            tolerated_number_of_failures = 3
          },
          v.monitor_config
        )
      }
    )
  }
}

resource "azurerm_traffic_manager_profile" "traffic_managers" {
  for_each = local.traffic_manager_profiles

  name                   = each.key
  resource_group_name    = each.value.resource_group_name
  profile_status         = each.value.profile_status
  traffic_routing_method = each.value.traffic_routing_method
  traffic_view_enabled   = each.value.traffic_view_enabled

  dns_config {
    relative_name = each.value.dns_config.relative_name
    ttl           = each.value.dns_config.ttl
  }

  monitor_config {
    protocol                    = each.value.monitor_config.protocol
    port                        = each.value.monitor_config.port
    path                        = each.value.monitor_config.path
    expected_status_code_ranges = each.value.monitor_config.expected_status_code_ranges

    dynamic "custom_header" {
      for_each = try(each.value.monitor_config.custom_headers, [])
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
    interval_in_seconds          = each.value.monitor_config.interval_in_seconds
    timeout_in_seconds           = each.value.monitor_config.timeout_in_seconds
    tolerated_number_of_failures = each.value.monitor_config.tolerated_number_of_failures
  }

  max_return = each.value.max_return

  tags = each.value.tags
}

locals {
  traffic_manager_external_end_points = flatten(
    [
      for k, v in try(local.traffic_manager_profiles, {}) : [
        for end_point_k, end_point_v in try(v.external_end_points, {}) : merge(
          {
            target         = null
            weight         = 100
            custom_headers = []
            enabled        = true
            geo_mappings   = null
            priority       = null
            subnets        = []
          },
          end_point_v,
          {
            name         = end_point_k
            key          = "${k}-${end_point_k}"
            profile_name = k
          }
        )
      ]
    ]
  )
}

resource "azurerm_traffic_manager_external_endpoint" "traffic_manager" {
  for_each = {
    for entry in local.traffic_manager_external_end_points : entry.key => entry
  }

  name       = each.value.name
  profile_id = azurerm_traffic_manager_profile.traffic_managers[each.value.profile_name].id
  target     = each.value.target
  weight     = each.value.weight

  dynamic "custom_header" {
    for_each = try(each.value.custom_headers, [])
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  enabled      = each.value.enabled
  geo_mappings = each.value.geo_mappings
  priority     = each.value.priority

  dynamic "subnet" {
    for_each = try(each.value.subnets, [])
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}

locals {
  traffic_manager_azure_end_points = flatten(
    [
      for k, v in try(local.traffic_manager_profiles, {}) : [
        for end_point_k, end_point_v in try(v.azure_end_points, {}) : merge(
          {
            weight         = 100
            custom_headers = []
            enabled        = true
            geo_mappings   = null
            priority       = null
            subnets        = []
          },
          end_point_v,
          {
            name         = end_point_k
            key          = "${k}-${end_point_k}"
            profile_name = k
          }
        )
      ]
    ]
  )
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic_manager" {
  for_each = {
    for entry in local.traffic_manager_azure_end_points : entry.key => entry
  }

  name               = each.value.name
  profile_id         = azurerm_traffic_manager_profile.traffic_managers[each.value.profile_name].id
  target_resource_id = each.value.target_resource_id
  weight             = each.value.weight

  dynamic "custom_header" {
    for_each = try(each.value.custom_headers, [])
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  enabled      = each.value.enabled
  geo_mappings = each.value.geo_mappings
  priority     = each.value.priority

  dynamic "subnet" {
    for_each = try(each.value.subnets, [])
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}

locals {
  traffic_manager_nested_end_points = flatten(
    [
      for k, v in try(local.traffic_manager_profiles, {}) : [
        for end_point_k, end_point_v in try(v.nested_end_points, {}) : merge(
          {
            weight                                = 100
            custom_headers                        = []
            enabled                               = true
            endpoint_location                     = null
            minimum_required_child_endpoints_ipv4 = null
            minimum_required_child_endpoints_ipv6 = null
            priority                              = null
            geo_mappings                          = null
            subnets                               = []
          },
          end_point_v,
          {
            name         = end_point_k
            key          = "${k}-${end_point_k}"
            profile_name = k
          }
        )
      ]
    ]
  )
}

resource "azurerm_traffic_manager_nested_endpoint" "traffic_manager" {
  for_each = {
    for entry in local.traffic_manager_nested_end_points : entry.key => entry
  }

  minimum_child_endpoints = each.value.minimum_child_endpoints
  name                    = each.value.name
  profile_id              = azurerm_traffic_manager_profile.traffic_managers[each.value.profile_name].id
  target_resource_id      = each.value.target_resource_id
  weight                  = each.value.weight

  dynamic "custom_header" {
    for_each = try(each.value.custom_headers, [])
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  enabled                               = each.value.enabled
  endpoint_location                     = each.value.endpoint_location
  minimum_required_child_endpoints_ipv4 = each.value.minimum_required_child_endpoints_ipv4
  minimum_required_child_endpoints_ipv6 = each.value.minimum_required_child_endpoints_ipv6
  priority                              = each.value.priority
  geo_mappings                          = each.value.geo_mappings

  dynamic "subnet" {
    for_each = try(each.value.subnets, [])
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}