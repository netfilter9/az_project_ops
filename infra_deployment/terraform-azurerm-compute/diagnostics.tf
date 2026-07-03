#
# Diagnostics
#
# This files includes key components associated with the diagnostics capabilities
# including a storage account for boot diagnostics and items associated with log 
# analytics 
#
# We heavily rely on inputs from the foundation for these components
#

locals {
  diagnostics = try(var.foundation.diagnostics, {})

  log_analytics = try(var.foundation.log_analytics, {})
}

data "azurerm_client_config" "diagnostics" {}

# look up log analytics workspace reference
data "azurerm_log_analytics_workspace" "diagnostics" {
  count = local.log_analytics != {} ? 1 : 0

  provider            = azurerm.diagnostics
  name                = local.log_analytics.workspace_name
  resource_group_name = local.log_analytics.resource_group_name
}

# lookup diagnostics storage account reference
data "azurerm_storage_account" "diagnostics" {
  count               = local.diagnostics != {} ? 1 : 0
  name                = local.diagnostics.storage_account_name
  resource_group_name = local.diagnostics.resource_group_name
}

# generate a short lived SAS token to use during the deployment
data "azurerm_storage_account_sas" "diagnostics" {
  count = local.diagnostics != {} ? 1 : 0

  connection_string = data.azurerm_storage_account.diagnostics[0].primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "30m")

  permissions {
    read    = false
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    tag     = false
    filter  = false
  }
}