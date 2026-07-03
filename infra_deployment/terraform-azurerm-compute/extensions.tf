#
# Extensions
#
# Azure extensions are messy and badly implemented, with poor attention to detail
# and limited standardisation.  As a result, we have to do a lot of work including
# various hacks, workarounds and voodoo
#

# generate a list of machines along with their ids and assocaited extensions
locals {
  extensions = flatten([
    for group_key, group_data in try(var.deployment.server_groups, {}) : [
      for host_key, host_data in try(group_data.hosts, []) : {
        hostname   = lower(host_key)
        extensions = lookup(group_data, "extensions", [])
        id = (
          try(group_data.legacy, false) ? azurerm_virtual_machine.legacy_vms[host_key].id :
          (
            group_data.os_type == "windows" ? azurerm_windows_virtual_machine.windows_vms[host_key].id :
            azurerm_linux_virtual_machine.linux_vms[host_key].id
          )
        )
      }
    ]
  ])
}

#----------------------------------------------------------
#
# LINUX Extensions
#
#----------------------------------------------------------

resource "azurerm_virtual_machine_extension" "extensions_OmsAgentForLinux" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "OmsAgentForLinux")
  }

  name                       = "OmsAgentForLinux"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "workspaceId" : "${data.azurerm_log_analytics_workspace.diagnostics[0].workspace_id}"
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "workspaceKey" : "${data.azurerm_log_analytics_workspace.diagnostics[0].primary_shared_key}"
  }
PROTECTED_SETTINGS

}
resource "azurerm_virtual_machine_extension" "AzureMonitorLinuxAgent" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "AzureMonitorLinuxAgent")
  }
 
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.6"
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "extensions_MonitorX64Linux" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "MonitorX64Linux")
  }

  name                       = "MonitorX64Linux"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.AzureCAT.AzureEnhancedMonitoring"
  type                       = "MonitorX64Linux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "system": "SAP"
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "workspaceKey" : "${data.azurerm_log_analytics_workspace.diagnostics[0].primary_shared_key}"
  }
PROTECTED_SETTINGS

  # race condition hack
  depends_on = [azurerm_virtual_machine_extension.extensions_OmsAgentForLinux]
}

resource "azurerm_virtual_machine_extension" "extensions_LinuxDiagnostic" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "LinuxDiagnostic")
  }

  name                       = "LinuxDiagnostic"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = true

  settings = templatefile("${path.module}/templates/ext_linux_diagnostic.json",
    {
      storage_account = data.azurerm_storage_account.diagnostics[0].name,
      resource_id     = each.value.id
  })

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName" : "${data.azurerm_storage_account.diagnostics[0].name}",
      "storageAccountSasToken": "${trimprefix(data.azurerm_storage_account_sas.diagnostics[0].sas, "?")}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [protected_settings]
  }

  # race condition hack
  depends_on = [azurerm_virtual_machine_extension.extensions_MonitorX64Linux]
}

resource "azurerm_virtual_machine_extension" "extensions_NetworkWatcherAgentLinux" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "NetworkWatcherAgentLinux")
  }

  name                       = "NetworkWatcherAgentLinux"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true

  # race condition hack
  depends_on = [azurerm_virtual_machine_extension.extensions_LinuxDiagnostic]
}

resource "azurerm_virtual_machine_extension" "extensions_DependencyAgentLinux" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "DependencyAgentLinux")
  }

  name                       = "DependencyAgentLinux"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

  # race condition hack
  depends_on = [azurerm_virtual_machine_extension.extensions_NetworkWatcherAgentLinux]
}

#----------------------------------------------------------
#
# WINDOWS EXTENSIONS
#
#----------------------------------------------------------

# handle windows domain join
resource "azurerm_virtual_machine_extension" "extensions_DomainJoin" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "DomainJoin")
  }

  name                 = "DomainJoin"
  virtual_machine_id   = each.value.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain

  settings = <<SETTINGS
    {
        "Name": "${local.foundation.windows_domain.domain_name}",
        "OUPath": "${local.foundation.windows_domain.ou_path}",
        "User": "${local.foundation.windows_domain.domain_user}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${local.foundation.windows_domain.domain_password}"
    }
PROTECTED_SETTINGS

}

resource "azurerm_virtual_machine_extension" "extensions_MicrosoftMonitoringAgent" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "MicrosoftMonitoringAgent")
  }

  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "workspaceId" : "${data.azurerm_log_analytics_workspace.diagnostics[0].workspace_id}"
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "workspaceKey" : "${data.azurerm_log_analytics_workspace.diagnostics[0].primary_shared_key}"
  }
PROTECTED_SETTINGS

}

resource "azurerm_virtual_machine_extension" "extensions_MonitorX64Windows" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "MonitorX64Windows")
  }

  name                       = "MonitorX64Windows"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.AzureCAT.AzureEnhancedMonitoring"
  type                       = "MonitorX64Windows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "system": "SAP"
  }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "extensions_VMDiagnosticsSettings" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "VMDiagnosticsSettings")
  }

  name                       = "Microsoft.Insights.VMDiagnosticsSettings"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "IaaSDiagnostics"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = templatefile("${path.module}/templates/ext_windows_diagnostics.json",
    {
      storage_account = data.azurerm_storage_account.diagnostics[0].name,
      resource_id     = each.value.id
  })

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName" : "${data.azurerm_storage_account.diagnostics[0].name}",
      "storageAccountSasToken": "${trimprefix(data.azurerm_storage_account_sas.diagnostics[0].sas, "?")}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "extensions_AzureNetworkWatcherExtension" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "AzureNetworkWatcherExtension")
  }

  name                       = "AzureNetworkWatcherExtension"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "extensions_DependencyAgentWindows" {
  for_each = {
    for vm in local.extensions : vm.hostname => vm if contains(vm.extensions, "DependencyAgentWindows")
  }

  name                       = "DependencyAgentWindows"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
}
/*
*/