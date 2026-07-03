
#Locals
locals {
  clusters = {
    for cluster_k, cluster_v in try(var.foundation.aks_clusters, {}) : cluster_k => merge(
      {
        name                = cluster_k
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        dns_prefix          = cluster_k

        node_resource_group = "${cluster_k}-nodes"
        sku_tier            = "Free"

        role_based_access_control = {
          enabled = true

          azure_active_directory = {
            managed                = true
            admin_group_object_ids = []
          }
        }

        identity = {
          type = "SystemAssigned"
        }

        default_node_pool = {
          name                = "default"
          enable_auto_scaling = true
          min_count           = 1
          max_count           = 1
          vm_size             = "Standard_B2ms"
        }

        node_pools = {}

        #TODO: if future creation of Windows Node Pools is required, then a windows_profile must be specified at cluster creation time
      },
      cluster_v,
      {
        #Overrides
      }
    )
  }

  node_pools = flatten([
    for cluster_k, cluster_v in local.clusters : {
      for nodepool_k, nodepool_v in cluster_v.node_pools : "${cluster_k}-${nodepool_k}" => merge(
        {
          #Defaults
        },
        nodepool_v,
        {
          #Overrides
        }
      )
    }
  ])

  user_assigned_identities = {
    for cluster_k, cluster_v in local.clusters : cluster_v.identity.name => merge(
      {
        #Defaults
      },
      cluster_v.identity,
      {
        #Overrides
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
        type                = "UserAssigned"
      }
    ) if cluster_v.identity.type == "UserAssigned"
  }

  ra_cluster_subnets = {
    for cluster_k, cluster_v in local.clusters : "${cluster_k}-NetworkContributor-${cluster_v.default_node_pool.subnet}" => {
      principal_id         = data.azurerm_user_assigned_identity.aks[cluster_v.identity.name].principal_id
      role_definition_name = "Network Contributor"
      scope                = data.azurerm_subnet.networks["${cluster_v.default_node_pool.network}-${cluster_v.default_node_pool.subnet}"].id
    } if cluster_v.identity.type == "UserAssigned"
  }

  ra_nodepool_subnets = {

  }

  ra_cluster_dns_zones = {
    for cluster_k, cluster_v in local.clusters : "${cluster_k}-DNSZoneContributor-${cluster_v.private_dns_zone}" => {
      principal_id         = data.azurerm_user_assigned_identity.aks[cluster_v.identity.name].principal_id
      role_definition_name = "Private DNS Zone Contributor"
      scope                = local.all_dns_zones[cluster_v.private_dns_zone].id
    } if cluster_v.identity.type == "UserAssigned"
  }

  ra_cluster_registries = {
    for entry in flatten([
      for cluster_k, cluster_v in local.clusters : [
        for registry_k in cluster_v.registries : {
          name                 = "${cluster_k}-AcrPull-${registry_k}"
          principal_id         = data.azurerm_kubernetes_cluster.aks[cluster_k].kubelet_identity[0].object_id
          role_definition_name = "AcrPull"
          scope                = registry_k
        }
      ]
    ]) : entry.name => entry
  }

  role_assignments = merge(local.ra_cluster_subnets, local.ra_nodepool_subnets, local.ra_cluster_dns_zones)

  role_assignments_postdeploy = merge(local.ra_cluster_registries)
}

resource "azurerm_user_assigned_identity" "aks" {
  for_each = local.user_assigned_identities

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
}

data "azurerm_user_assigned_identity" "aks" {
  for_each = local.user_assigned_identities

  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [
    azurerm_user_assigned_identity.aks
  ]
}

resource "azurerm_role_assignment" "aks" {
  for_each = local.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "aks-postdeploy" {
  for_each = local.role_assignments_postdeploy

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = local.clusters

  name                            = each.value.name
  dns_prefix                      = each.value.dns_prefix
  location                        = each.value.location
  resource_group_name             = each.value.resource_group_name
  api_server_authorized_ip_ranges = try(each.value.api_server_authorized_ip_ranges, null)
  automatic_channel_upgrade       = try(each.value.automatic_channel_upgrade, null)
  disk_encryption_set_id          = try(each.value.disk_encryption_set_id, null) #TODO: Refactor to reference TF resource or data entity
  kubernetes_version              = try(each.value.kubernetes_version, null)
  node_resource_group             = try(each.value.node_resource_group, null)
  private_cluster_enabled         = try(each.value.private_cluster_enabled, null)
  private_dns_zone_id             = try(each.value.private_dns_zone, null) != null ? local.all_dns_zones[each.value.private_dns_zone].id : null
  sku_tier                        = try(each.value.sku_tier, null)
  tags                            = {} #TODO: Add support for tags = {}

  default_node_pool {
    name                         = each.value.default_node_pool.name
    vm_size                      = each.value.default_node_pool.vm_size
    zones                        = try(each.value.default_node_pool.zones, null)
    enable_auto_scaling          = try(each.value.default_node_pool.enable_auto_scaling, null)
    max_count                    = try(each.value.default_node_pool.enable_auto_scaling, null) == true ? each.value.default_node_pool.max_count : null
    min_count                    = try(each.value.default_node_pool.enable_auto_scaling, null) == true ? each.value.default_node_pool.min_count : null
    node_count                   = try(each.value.default_node_pool.enable_auto_scaling, null) == true ? try(each.value.default_node_pool.node_count, null) : each.value.default_node_pool.node_count
    enable_host_encryption       = try(each.value.default_node_pool.enable_host_encryption, null)
    enable_node_public_ip        = try(each.value.default_node_pool.enable_node_public_ip, null)
    max_pods                     = try(each.value.default_node_pool.max_pods, null)
    only_critical_addons_enabled = try(each.value.default_node_pool.only_critical_addons_enabled, null)
    orchestrator_version         = try(each.value.default_node_pool.orchestrator_version, null)
    os_disk_size_gb              = try(each.value.default_node_pool.os_disk_size_gb, null)
    os_disk_type                 = try(each.value.default_node_pool.os_disk_type, null)
    type                         = try(each.value.default_node_pool.type, null)
    vnet_subnet_id               = try(each.value.default_node_pool.subnet, null) != null ? azurerm_subnet.networks["${each.value.default_node_pool.network}-${each.value.default_node_pool.subnet}"].id : null
    #TODO: Add support for ignore_changes node_count when enable_auto_scaling is true
    #NOT SUPPORTED
    # dynamic node_labels { }
    # upgrade_settings { }
    # tags { }
  }

  # removed in latest provider version
  # dynamic "addon_profile" {
  #   for_each = try(each.value.addon_profile, null) != null ? [each.value.addon_profile] : []

  #   content {
  #     dynamic "aci_connector_linux" {
  #       for_each = try(addon_profile.value.aci_connector_linux, null) != null ? [addon_profile.value.aci_connector_linux] : []

  #       content {
  #         enabled     = aci_connector_linux.value.enabled
  #         subnet_name = aci_connector_linux.value.enabled == true ? aci_connector_linux.value.subnet_name : null #TODO: Refactor to by-reference to TF resource/data??
  #       }
  #     }

  #     dynamic "azure_policy" {
  #       for_each = try(addon_profile.value.azure_policy, null) != null ? [addon_profile.value.azure_policy] : []

  #       content {
  #         enabled = azure_policy.value.enabled
  #       }
  #     }

  #     dynamic "http_application_routing" {
  #       for_each = try(addon_profile.value.http_application_routing, null) != null ? [addon_profile.value.http_application_routing] : []

  #       content {
  #         enabled = http_application_routing.value.enabled
  #       }
  #     }

  #     dynamic "kube_dashboard" {
  #       for_each = try(addon_profile.value.kube_dashboard, null) != null ? [addon_profile.value.kube_dashboard] : []

  #       content {
  #         enabled = kube_dashboard.value.enabled
  #       }
  #     }

  #     dynamic "oms_agent" {
  #       for_each = try(addon_profile.value.oms_agent, null) != null ? [addon_profile.value.oms_agent] : []

  #       content {
  #         enabled                    = oms_agent.value.enabled
  #         log_analytics_workspace_id = oms_agent.value.enabled == true ? oms_agent.value.log_analytics_workspace_id : null #TODO: Refactor to by-reference to TF resource/data
  #       }
  #     }
  #   }
  # }

  dynamic "auto_scaler_profile" {
    for_each = try(each.value.autoscaler_profile, null) != null ? [each.value.autoscaler_profile] : []

    content {
      balance_similar_node_groups      = try(autoscaler_profile.value.balance_similar_node_groups, null)
      expander                         = try(autoscaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(autoscaler_profile.value.max_graceful_termination_sec, null)
      new_pod_scale_up_delay           = try(autoscaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(autoscaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(autoscaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(autoscaler_profile.value.scale_down_delay_after_failure, null)
      scale_down_unneeded              = try(autoscaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(autoscaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(autoscaler_profile.value.scale_down_utilization_threshold, null)
      scan_interval                    = try(autoscaler_profile.value.scan_interval, null)
      skip_nodes_with_local_storage    = try(autoscaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(autoscaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  dynamic "identity" {
    for_each = try(each.value.identity, null) != null ? [each.value.identity] : []

    content {
      type = identity.value.type
      #user_assigned_identity_id = identity.value.type == "UserAssigned" ? azurerm_user_assigned_identity.aks[identity.value.name].id : null
      # user_assigned_identity_id = identity.value.type == "UserAssigned" ? replace(azurerm_user_assigned_identity.aks[identity.value.name].id, "resourceGroups", "resourcegroups") : null
      #NOTE: The odd replace() function above is for https://github.com/terraform-providers/terraform-provider-azurerm/issues/10406 but didn't resolve the issue.  Still looking to understand what's going on...
    }
  }

  dynamic "linux_profile" {
    for_each = try(each.value.linux_profile, null) != null ? [each.value.linux_profile] : []

    content {
      admin_username = linux_profile.value.admin_username

      ssh_key {
        key_data = linux_profile.value.ssh_key.key_data #TODO: Support through cloudbuilder secrets?
      }
    }
  }

  dynamic "network_profile" {
    for_each = try(each.value.network_profile, null) != null ? [each.value.network_profile] : []

    content {
      network_plugin = network_profile.value.network_plugin
      # network_mode       = try(each.value.network_profile.network_mode, null)   ### NOT SUPPORTED - Deprecated by Azure
      network_policy     = try(network_profile.value.network_policy, null)
      dns_service_ip     = try(network_profile.value.dns_service_ip, null)
      docker_bridge_cidr = try(network_profile.value.docker_bridge_cidr, null)
      outbound_type      = try(network_profile.value.outbound_type, null)
      pod_cidr           = try(network_profile.value.pod_cidr, null)
      service_cidr       = try(network_profile.value.service_cidr, null)
      load_balancer_sku  = try(network_profile.value.load_balancer_sku, null)

      dynamic "load_balancer_profile" {
        for_each = try(network_profile.value.load_balancer_profile, null) != null ? [network_profile.value.load_balancer_profile] : []

        content {
          outbound_ports_allocated  = try(load_balancer_profile.value.outbound_ports_allocated, null)
          idle_timeout_in_minutes   = try(load_balancer_profile.value.idle_timeout_in_minutes, null)
          managed_outbound_ip_count = try(load_balancer_profile.value.managed_outbound_ip_count, null)

          #Not Supported
          # outbound_ip_prefix_ids = try(load_balancer_profile.value.outbound_ip_prefix_ids, null)
          # outbound_ip_address_ids = try(load_balancer_profile.value.outbound_ip_address_ids, null)
        }
      }
    }

  }

  # removed in latest provider version
  # dynamic "role_based_access_control" {
  #   for_each = try(each.value.role_based_access_control, null) != null ? [each.value.role_based_access_control] : []

  #   content {
  #     enabled = role_based_access_control.value.enabled

  #     dynamic "azure_active_directory" {
  #       for_each = try(role_based_access_control.value.azure_active_directory, null) != null ? [role_based_access_control.value.azure_active_directory] : []

  #       content {
  #         managed = azure_active_directory.value.managed

  #         #TODO: Convert admin_group_object_ids to data.azuread_groups reference (or multiple data.azuread_group references)
  #         tenant_id              = azure_active_directory.value.managed == true ? try(azure_active_directory.value.tenant_id, null) : null
  #         admin_group_object_ids = azure_active_directory.value.managed == true ? try(azure_active_directory.value.admin_group_object_ids, null) : null

  #         client_app_id     = azure_active_directory.value.managed == false ? azure_active_directory.value.client_app_id : null
  #         server_app_id     = azure_active_directory.value.managed == false ? azure_active_directory.value.server_app_id : null
  #         server_app_secret = azure_active_directory.value.managed == false ? azure_active_directory.value.server_app_secret : null
  #       }
  #     }
  #   }
  # }

  #TODO: KNOWN ISSUE: If a user specifies the service_principal form of cluster identity, the the default identity {} block in locals will cause a conflict (both identity {} and service_principal {} cannot be present)
  dynamic "service_principal" {
    for_each = try(each.value.service_principal, null) != null ? [each.value.service_principal] : []

    content {
      client_id     = each.value.service_principal.client_id
      client_secret = each.value.service_principal.client_secret
    }
  }

  dynamic "windows_profile" {
    for_each = try(each.value.windows_profile, null) != null ? [each.value.windows_profile] : []

    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
    }
  }

  depends_on = [
    azurerm_role_assignment.aks
  ]
  #TODO: Conditionally depend on the AzureRm_Role_Assignments for this cluster if UserAssigned identities are used
  # each.value.identity.type == "UserAssigned" ? azurerm_role_assignment : null

  #TODO: Conditionally depend on an AzureFirewall ApplicationRuleCollection if Private Endpoints are used
}

data "azurerm_kubernetes_cluster" "aks" {
  for_each = local.clusters

  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

output "ra_cluster_registries" {
  value = local.ra_cluster_registries
}