#
# OS Account
#
# All VMs must be initialised with an administrator account with associated 
# security controls
#
# There is a precedence to the security options
# 1. SSH key
# 2. Password from TF_VAR_admin_password environment variable
# 3. Password hardcoded in os_account block
# 4. Lookup against key vault - WARNING - can result in VM rebuild on each terraform apply
#

locals {
  # Initialise defaults in input deplyment.os_account data
  os_account = merge(
    {
      ssh_key_file       = null
      password_key_vault = null
      admin_password     = var.admin_password
    },
    try(var.deployment.os_account, {})
  )
}

# if key vault is specified, lookup password
# if we are using a local key vault we need to make sure it has been created first
data "azurerm_key_vault" "os_account" {
  count               = local.os_account.password_key_vault != null ? 1 : 0
  name                = local.os_account.password_key_vault.key_vault_name
  resource_group_name = local.os_account.password_key_vault.resource_group_name
  depends_on          = [azurerm_key_vault.key_vault, local.all_resource_groups]
}

# lookup the associated password in the key value
# if we are using a local key value, we need to wait to make sure it has been created first
data "azurerm_key_vault_secret" "os_account" {
  count        = local.os_account.password_key_vault != null ? 1 : 0
  name         = local.os_account.password_key_vault.secret_name
  key_vault_id = data.azurerm_key_vault.os_account[0].id
  depends_on   = [azurerm_key_vault_secret.key_vault]
}