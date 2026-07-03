/*
Azure Backup will need SQL sysadmin privilege for doing backups.
It will create NT Service\AzureWLBackupPluginSvc account on the selected VMs 
which needs to be added to SQL login and given SQL sysadmin privilege. 
In case of a SQL Marketplace VM, 
Azure Backup will invoke SQL IaaS extension to automatically get required permissions

Reference : https://docs.microsoft.com/en-us/azure/backup/backup-azure-sql-database
*/

# Azure Backup service will install a workload backup extension on the VM.
resource "azurerm_resource_group_template_deployment" "sqldb_workload_agent" {
  for_each = {
    for vm in local.windows_vms : vm.hostname => vm if vm.enable_sql_workload_agent
  }
  name = "sqldb_workload_agent_${each.key}"

  # This refers to RG of recovery vault service, on which backup will be configured.
  resource_group_name = local.foundation.recovery_vault.resource_group_name

  # arm template to install sql workload on windows vm
  template_content = file("${path.module}/templates/arm_sql_workload_agent.json")

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters_content = jsonencode({
    "vmName"          = each.key,
    "vmResourceGroup" = local.all_resource_groups[each.value.resource_group_name].name,
    "vaultName"       = local.foundation.recovery_vault.name
  })
  deployment_mode = "Incremental"

  depends_on = [azurerm_windows_virtual_machine.windows_vms,
  azurerm_mssql_virtual_machine.sqldb]
}