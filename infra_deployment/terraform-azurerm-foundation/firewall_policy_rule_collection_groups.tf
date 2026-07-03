locals {
  firewall_policy_rule_collection_groups_input = flatten(
    [
      for firewall_policy in try(var.foundation.firewall_policies, []) : [
        for rule_collection_group in try(firewall_policy.rule_collection_groups, []) : merge(
          {
            lookup = false
            tags   = try(var.foundation.tags, {})
          },
          rule_collection_group,
          {
            name                 = "${firewall_policy.name}-${rule_collection_group.name}"
            firewall_policy_name = firewall_policy.name
            firewall_association = firewall_policy.firewall_association
          }
        )
      ]
    ]
  )
}

resource "azurerm_firewall_policy_rule_collection_group" "firewall_policy_rule_collection_groups" {
  for_each = {
    for entry in local.firewall_policy_rule_collection_groups_input : entry.name => entry if entry.lookup == false
  }

  name = each.value.name
  firewall_policy_id = try(
    each.value.firewall_policy_id,
    local.firewall_policies_all[each.value.firewall_policy_name].id
  )
  priority = each.value.priority

  dynamic "application_rule_collection" {
    for_each = try(each.value.application_rule_collections, [])
    content {
      name     = application_rule_collection.value.name
      action   = application_rule_collection.value.action
      priority = application_rule_collection.value.priority
      dynamic "rule" {
        for_each = try(application_rule_collection.value.rules, [])
        content {
          name                  = rule.value.name
          description           = try(rule.value.description, null)
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_urls      = try(rule.value.destination_urls, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
          destination_fqdn_tags = try(rule.value.destination_fqdn_tags, null)
          terminate_tls         = try(rule.value.terminate_tls, null)
          web_categories        = try(rule.value.web_categories, null)

          dynamic "protocols" {
            for_each = try(rule.value.protocols, [])
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = try(each.value.network_rule_collections, [])

    content {
      name     = network_rule_collection.value.name
      action   = network_rule_collection.value.action
      priority = network_rule_collection.value.priority
      dynamic "rule" {
        for_each = try(network_rule_collection.value.rules, [])
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          destination_ports     = rule.value.destination_ports
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_ip_groups = try(rule.value.destination_ip_groups, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = try(each.value.nat_rule_collections, [])

    content {
      name     = nat_rule_collection.value.name
      action   = nat_rule_collection.value.action
      priority = nat_rule_collection.value.priority
      dynamic "rule" {
        for_each = try(nat_rule_collection.value.rules, [])
        content {
          name                = rule.value.name
          protocols           = rule.value.protocols
          source_addresses    = try(rule.value.source_addresses, null)
          source_ip_groups    = try(rule.value.source_ip_groups, null)
          destination_address = try(
            rule.value.destination_address,
            local.all_firewalls[each.value.firewall_association].virtual_hub[0].public_ip_addresses[0], 
            null
          )
          destination_ports   = try(rule.value.destination_ports, null)
          translated_address  = try(rule.value.translated_address, null)
          translated_fqdn     = try(rule.value.translated_fqdn, null)
          translated_port     = try(rule.value.translated_port, null)
        }
      }
    }
  }

  depends_on = [
    azurerm_firewall.firewalls
  ]
}