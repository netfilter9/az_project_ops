locals {
  firewall_policies_input = [
    for entry in try(var.foundation.firewall_policies, []) : merge(
      {
        lookup              = false
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        tags                = try(var.foundation.tags, {})
      },
      entry,
      {}
    )
  ]
}

resource "azurerm_firewall_policy" "firewall_policies" {
  for_each = {
    for entry in local.firewall_policies_input : entry.name => entry if entry.lookup == false
  }

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  # NOTE:
  # All the code blocks below are so far untested

  # base_policy_id = try(
  #     each.value.base_policy_id,
  #     azurerm_firewall_policy.firewall_policies["base_policy_name"].id,
  #     data.azurerm_firewall_policy.firewall_policies["base_policy_name"].id,
  #     null)
  # private_ip_ranges = try(each.value.private_ip_ranges, null)
  sku = try(each.value.sku, null)
  threat_intelligence_mode = try(each.value.threat_intelligence_mode, null)

  dynamic "dns" {
    for_each = try([each.value.dns], [])
    content {
      proxy_enabled = try(dns.value.proxy_enabled, null)
      servers = try(dns.value.servers, null)
    }
  }

  # dynamic "identity" {
  #   for_each = try([each.value.identity], [])
  #   content {
  #     type = identity.value.type
  #     identity_ids = identity.value.type
  #   }
  # }

  # dynamic "insights" {
  #   for_each = try([each.value.insights], [])
  #   content {
  #     enabled = insights.value.enabled
  #     default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
  #     retention_in_days = try(insights.value.retention_in_days, null)
  #     dynamic "log_analytics_workspace" {
  #       for_each = try(insights.value.log_analytics_workspaces, [])
  #       content {
  #         id = log_analytics_workspace.value.id
  #         firewall_location = log_analytics_workspace.value.firewall_location
  #       }
  #     }    
  #   }
  # }

  dynamic "intrusion_detection" {
    for_each = try([each.value.intrusion_detection], [])
    content {
      mode = try(intrusion_detection.value.mode, null)

      dynamic "signature_overrides" {
        for_each = try(intrusion_detection.value.signature_overrides, [])
        content {
          id = try(signature_overrides.value.id, null)
          state = try(signature_overrides.value.state, null)
        }
      }

      dynamic "traffic_bypass" {
        for_each = try(intrusion_detection.value.traffic_bypasses, [])
        content {
          name = traffic_bypass.value.name
          protocol = traffic_bypass.value.protocol
          description = try(traffic_bypass.value.description, null)
          destination_addresses = try(traffic_bypass.value.destination_addresses, null)
          destination_ip_groups= try(traffic_bypass.value.destination_ip_groups, null)
          destination_ports= try(traffic_bypass.value.destination_ports, null)
          source_addresses= try(traffic_bypass.value.source_addresses, null)
          source_ip_groups= try(traffic_bypass.value.source_ip_groups, null)
        }
      }
    }
  }



  # dynamic "threat_intelligence_allowlist" {
  #   for_each = try([each.value.threat_intelligence_allowlist], [])
  #   content {
  #     fqdns = try(threat_intelligence_allowlist.value.fqdns, null)
  #     ip_addresses = try(threat_intelligence_allowlist.value.ip_addresses, null)
  #   }
  # }

  # dynamic "tls_certificate" {
  #   for_each = try(each.value.tls_certificate)
  #   content {
  #     key_vault_secret_id = try(tls_certificate.value.key_vault_secret_id, null)
  #     name = try(tls_certificate.value.name, null)
  #   }
  # }

  tags = try(each.value.tags, {})
}

data "azurerm_firewall_policy" "firewall_policies" {
  for_each = {
    for entry in local.firewall_policies_input : entry.name => entry if entry.lookup == true
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

locals {
  firewall_policies_all = merge(
    azurerm_firewall_policy.firewall_policies,
    data.azurerm_firewall_policy.firewall_policies
  )
}