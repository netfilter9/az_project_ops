#
# Resource Groups
#
# IaaS resources can be deployed to one or multiple resource groups 
# 
# We recommend that you create a new resource group for each new application deployment
# Using a new resoure group as a "container" for a specific deployment makes it much
# easier to manage the system across its lifecycle.
# However, if a client requires deployments to be across multiple resource groups, this can
# also be done.
#
# This resource module supports both single and multi resource group deployments
# It is backwards compatible with input json where a resource_group object is defined
# as well as the new resource_groups array.
#
# To use multiple resource groups, you can define an array of named resource groups
# Note: Just make sure that one, and only one is marked as "is_default = true".  This will
# be used for all resources where an alternative "resource_group_name" is not defined
#
# By default, we assume that all resource groups need to be created. However, If a client 
# requires you to deploy to existing resource groups, that can be achieved using a lookup.
# You just need to add
#   "lookup": true
# to your resource group config block in the input json.
#
# Note: If the single resource_group object is defined, it will be treated as the default
# resource group. We do not recommend combining resource_group objects with
# resource_groups array.
#
# Logic overview:
# * Generate list of resource groups to lookup/create by merging resource_group
# objects and resource_groups arrays.
# * Create resource group where lookup is not true
# * Look up references for ALL defined groups - these are used when building other 
#   resources
# * Identify the default resource group and store the reference for use as a default

locals {
  # default resource group action to create if lookup not explicitly specified
  resource_groups = merge(
    {
      for v in try(var.deployment.resource_groups, []) : v.name => merge(
        {
          # overrideable defaults
          lookup     = false
          is_default = false
        },
        v,
        {
          # fixed values and internal references
          tags = merge(local.tags, try(v.tags, {}))
        }
      )
    },
    {
      for v in [try(var.deployment.resource_group, {})] : v.name => merge(
        {
          # overrideable defaults
          lookup     = false
          is_default = true
        },
        v,
        {
          # fixed values and internal references
          tags = merge(local.tags, try(v.tags, {}))
        }
      ) if v != {}
    }
  )
}

resource "azurerm_resource_group" "resource_group" {
  for_each = {
    for k, v in local.resource_groups : k => v if !v.lookup
  }

  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}

# look the existing (or newly created) resource group to use as a reference for all
# other resource creations
data "azurerm_resource_group" "resource_group" {
  for_each = {
    for k, v in local.resource_groups : k => v if v.lookup
  }
  name = each.value.name

  depends_on = [azurerm_resource_group.resource_group]
}

locals {
  all_resource_groups = merge(
    azurerm_resource_group.resource_group,
    data.azurerm_resource_group.resource_group
  )
}

# Obtain default resource group reference
#
# Note: I know this looks odd. We have to write the code this way to address issues 
# with the way Terraform builds dependency graphs.
# We need the resource group name reference from the data block to ensure that 
# Terraform builds a dependency between the new resource and the resource group
# We need the set the location based on input variables to ensure that Terraform
# knows the location at plan generation time. Without this, Terraform would
# destroy and recreate every resource on every deployment as it is unable to 
# verify that existing resources are built in the correct location
# The [0] on the end ensures that we don't end up with multiple defaults
# we aren't going to error check for this though
locals {
  default_resource_group = [
    for k, v in local.resource_groups : {
      name     = local.all_resource_groups[k].name
      location = v.location
    } if v.is_default
  ][0]
}

# debug output
output "default_rg" {
  value = local.default_resource_group
}
/*
*/