locals {
  mssql_server = {
    for k, v in try(var.deployment.mssql_server, {}) : k => merge(
    {
      lookup_id                    = null
      resource_group_name                = local.default_resource_group.name
      location                           = local.default_resource_group.location
      administrator_login                = null
      administrator_login_password       = null     
      version                            = "12.0"
      
    },
    v,
    {
        tags = merge(
          local.tags,
          try(v.tags, {})
          )
    }    
  )
}
}

resource "azurerm_mssql_server" "sqldb" {
  for_each = {
    for k, v in local.mssql_server : k => v if v.lookup_id == null
  }  
  name                         = lower(each.key)
  resource_group_name          = local.all_resource_groups[each.value.resource_group_name].name
  location                     = each.value.location
  version                      = each.value.version
  administrator_login          = each.value.administrator_login
  administrator_login_password = each.value.administrator_login_password
  tags                         = each.value.tags
}