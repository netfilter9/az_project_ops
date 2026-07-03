#
# Automation Accounts
#
# This file contains all the resources definitions required to provision
# Automation Accounts
#
# Logic overview:
# * create a list of automation accounts to create
# * create them 
# * retrieve diagnostics settings details
# * generate list of diagnostics monitoring settings to create
# * create diagnostics monitoring settings if required

# create a list of automation accounts to create by combining
# defaults, inputs, fixed values and internal references  
locals {
  automation_accounts = {
    for k, v in try(var.foundation.automation_accounts, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
      },
      v,
      {
        # internal references and fixed values
        sku_name = "Basic"
      }
    )
  }
}

#create automation accounts
resource "azurerm_automation_account" "automation_account" {
  for_each = local.automation_accounts

  name                = each.key
  location            = each.value.location
  resource_group_name = local.all_resource_groups[each.value.resource_group_name].name
  sku_name            = each.value.sku_name
}

# lookup diagnostic categories for each automation account
data "azurerm_monitor_diagnostic_categories" "automation_account" {
  for_each    = azurerm_automation_account.automation_account
  resource_id = each.value.id
}

# Generate diagnostics settings, but only if storage account or log analytics
# workspace has been provided
locals {
  automation_account_diagnostics_settings = {
    for k, v in try(var.foundation.automation_accounts, {}) : k => merge(
      {
        # overrideable defaults
        location            = local.default_resource_group.location
        resource_group_name = local.default_resource_group.name
      },
      v,
      {
        name                       = "${k}-diagnostic-setting"
        target_resource_id         = azurerm_automation_account.automation_account[k].id,
        logs                       = data.azurerm_monitor_diagnostic_categories.automation_account[k].logs
        metrics                    = data.azurerm_monitor_diagnostic_categories.automation_account[k].metrics
        enabled                    = true
        retention_policy_enabled   = try(v.diagnostics.storage_account_name, null) != null ? true : false
        retention_policy_days      = try(v.diagnostics.storage_account_name, null) != null ? try(v.diagnostics.retention, 30) : null
        log_analytics_workspace_id = try(data.azurerm_log_analytics_workspace.log_analytics[v.diagnostics.log_analytics_workspace_name].id, null)
        storage_account_id         = try(local.all_storage_accounts[v.diagnostics.storage_account_name].id, null)
      }
    )
    if(try(v.diagnostics, {}) != {})
  }
}

#create moniter diagnostic setting components
resource "azurerm_monitor_diagnostic_setting" "automation_account" {
  for_each = local.automation_account_diagnostics_settings

  name                       = each.value.name
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id
  storage_account_id         = each.value.storage_account_id

  dynamic "log" {
    for_each = each.value.logs

    content {
      category = log.value
      enabled  = each.value.enabled

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.retention_policy_enabled
        days    = each.value.retention_policy_days
      }
    }
  }

  dynamic "metric" {
    for_each = each.value.metrics

    content {
      category = metric.value
      enabled  = each.value.enabled

      #retention policy applies when output type is storage account
      retention_policy {
        enabled = each.value.retention_policy_enabled
        days    = each.value.retention_policy_days
      }
    }
  }
}
/*
*/