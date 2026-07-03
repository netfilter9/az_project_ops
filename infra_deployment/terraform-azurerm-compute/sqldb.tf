locals {
  mssql_config = merge(
    {
      license_type                       = "PAYG",
      r_services_enabled                 = true,
      connectivity_port                  = "1433",
      connectivity_type                  = "PRIVATE",
      connectivity_username              = null,
      connectivity_password              = null,
      enable_auto_patching               = true,
      auto_patching_dayofweek            = "Sunday",
      auto_patching_win_duration_in_min  = "60",
      auto_patching_window_starting_hour = "2"
    },
    try(var.deployment.mssql_config, {}),
    {
      tags = merge(local.tags, try(var.deployment.mssql_config.tags, {}))
    }
  )
}

# create resource for managing MS sql on virtual machine
# It will add SQL IaaS extension on Azure VM
resource "azurerm_mssql_virtual_machine" "sqldb" {
  for_each = {
    for vm in local.windows_vms : vm.hostname => vm if vm.install_mssql
  }

  virtual_machine_id    = azurerm_windows_virtual_machine.windows_vms[each.key].id
  sql_license_type      = local.mssql_config.license_type
  r_services_enabled    = local.mssql_config.r_services_enabled
  sql_connectivity_port = local.mssql_config.connectivity_port
  sql_connectivity_type = local.mssql_config.connectivity_type

  sql_connectivity_update_password = try(var.secrets[regex("secret:(.*)", local.mssql_config.connectivity_password)[0]], local.mssql_config.connectivity_password)
  sql_connectivity_update_username = local.mssql_config.connectivity_username

  dynamic "auto_patching" {
    for_each = local.mssql_config.enable_auto_patching ? [1] : []
    content {
      day_of_week                            = local.mssql_config.auto_patching_dayofweek
      maintenance_window_duration_in_minutes = local.mssql_config.auto_patching_win_duration_in_min
      maintenance_window_starting_hour       = local.mssql_config.auto_patching_window_starting_hour
    }
  }

  # optional storage configuration 
  dynamic "storage_configuration" {
    for_each = try(local.mssql_config.storage_configuration, null) != null ? [1] : []

    content {
      disk_type             = local.mssql_config.storage_configuration.disk_type
      storage_workload_type = local.mssql_config.storage_configuration.storage_workload_type

      dynamic "data_settings" {
        for_each = try(local.mssql_config.storage_configuration.data_settings, null) != null ? [1] : []

        content {
          default_file_path = local.mssql_config.storage_configuration.data_settings.default_file_path
          luns              = local.mssql_config.storage_configuration.data_settings.luns
        }
      }

      dynamic "log_settings" {
        for_each = try(local.mssql_config.storage_configuration.log_settings, null) != null ? [1] : []

        content {
          default_file_path = local.mssql_config.storage_configuration.log_settings.default_file_path
          luns              = local.mssql_config.storage_configuration.log_settings.luns
        }
      }

      dynamic "temp_db_settings" {
        for_each = try(local.mssql_config.storage_configuration.temp_db_settings, null) != null ? [1] : []

        content {
          default_file_path = local.mssql_config.storage_configuration.temp_db_settings.default_file_path
          luns              = local.mssql_config.storage_configuration.temp_db_settings.luns
        }
      }
    }
  }

  tags = local.mssql_config.tags

  depends_on = [azurerm_windows_virtual_machine.windows_vms, azurerm_virtual_machine_data_disk_attachment.disks]
}
