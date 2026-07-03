/*
The two resources will be deployed here via arm template
1. SQL DB backup policy (With Full, Differential and Log backup)
2. Enabling backup for SQL DB on Azure VM with the newly created backup policy

Reference : https://docs.microsoft.com/en-us/azure/backup/backup-azure-sql-database
*/

# deploy arm template on the virtual machine
resource "azurerm_resource_group_template_deployment" "sqldb_backup" {
  for_each = {
    for vm in local.windows_vms : vm.hostname => vm if vm.enable_sqldb_backup
  }

  name = "sqldb_backup_${each.key}"

  # This refers to RG of recovery vault service, on which backup will be configured.
  resource_group_name = local.foundation.recovery_vault.resource_group_name
  template_content    = var.sqldb_backup_template

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters_content = jsonencode({
    "vmName"          = each.key,
    "vmResourceGroup" = local.all_resource_groups[each.value.resource_group_name].name
  })

  deployment_mode = "Incremental"
  depends_on = [azurerm_windows_virtual_machine.windows_vms,
    azurerm_mssql_virtual_machine.sqldb,
  azurerm_resource_group_template_deployment.sqldb_workload_agent]
}