# v3.5.0
* contribution from vadim.petiul@accenture.com
* added queue, table, and data lake gen2 services, and additional storage account settings to storage accounts 
* tested with terraform v1.1.8 and azurerm provider v3.5.0

# v3.4.0
* contribution from vadim.petiul@accenture.com
* completed adding basic support for azure data factory
* tested with terraform v1.1.8 and azurerm provider v3.2.0

# v3.3.0
* contribution from steven.t.urwin@accenture.com
* added diagnostics support for storage accounts
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v3.2.0
* contribution from steven.t.urwin@accenture.com
* added blob and container retention support to storage accounts
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v3.1.1
* fixed "bug" where storage accounts allowed public access by default following updates to azure provider defaults
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v3.1.0
* contribution from steven.t.urwin@accenture.com
* added support to assign disk groups to specific luns
* tested with terraform 1.1.7 and azurerm 3.0.2

# v3.0.0
* WARNING: Contains Interface breaking changes
* includes changes to how availability zones are handled for load balancers and disks
* includes changes to how service plans are applied to data factory resources
* includes enhancements to handling of shared disks
* includes changes to how SQL server backups and workload agents are handled - would result in a rebuild of these components
* contribution from steven.t.urwin@accenture.com
* major upgrade to Azure provider version
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v2.7.1
* private endpoints for storage accounts now inherit tags from the storage account (unless overridden)
* tested with terraform 1.1.5 and azurerm 2.96.0

# v2.7.0
* improvement to ppg/avset handling
* you no longer need to specify ppg on the vm if the ppg is associated with an avset
* tested with terraform 1.1.4 and azurerm 2.94.0

# v2.6.1
* fixed issue with storage account end points
* tested with terraform 1.1.4 and azurerm 2.93.1

# v2.6.0
* added workaround for issues casued by inclusion of hyper_v_generation on disks in 2.89.0
* tested with terraform 1.11.0 and azurerm 2.89.0 (required upgrade)

# v2.5.1
* tweaks to storage accounts to allow enable_https_traffic_only to be overridden and to allow fileshare protocol to be changed from default
* tested with terraform 1.0.11 and azurerm 2.88.1

# v2.5.0
* added extended support for SQL Server DBs - you can now set the storage profile
* fixed issue with SQL db username and password being swapped over
* added support for SQL DB password injection using secret
* fixed deprecation warnings for loadbalancers (quick fix - further enhancements are possible)
* tested with Terraform 1.0.11 and azurerm 2.87.0

# v2.4.0
* added load_balancer_v2 which provides more comprehensive load balance support (at the cost of input data complexity)
* tested with terraform 1.0.8 and azurerm 2.80.0

# v2.3.1
* fixed resource/data lookups to ensure resources are either created or lookedup - not both
* this resolves some issues seen with unexpected cascading rebuilds
* also removed legacy nsgs.tf which should have been deleted a long time ago.
* tested with terraform 1.0.7 and azurerm 2.80.0

# v2.3.0
* added lifecycle ignore for disks
* this fix was implemented to support a specific client reqirement involving machine cloning 

# v2.2.1
* updated code to resolve storage deprecation warning
* ran teraform fmt
* added regression test example - please ignore, this is for testing patches
* updated minimum provider version to 2.78.0
* NOTE: provider version 2.79.0 is broken
* tested with azurerm provider 2.79.0 and terraform v1.0.8

# v2.2.0
* contribution from Pachniak, Paul J.
* added configurable parameters for windows servers patching and auto updates

# v2.1.1
* added admin_password to lifcycle ignore_changes for windows and linux virtual machines
* it's unlikely that most customers would want to use terraform to manage admin passwords on thier vms and a detected change results in a full rebuild

# v2.1.0
* added support for "legacy" vm definition - required for situation where machines are build from an image which includes data disks
* don't use this new feature without first discussing with steven.t.urwin@accenture.com
* fixed error in schema reference to application security groups

# v2.0.1
* fixed race condition error on destroy where nics are assocaited with network security groups 

# v2.0.0
* WARNING: Interface breaking change
* improved handling of NSG and ASGs (see examples/asg_nsg)
* ASGs and NSGs can now be created (or referenced) and associated with servers at either the group, host or nic level
* NOTE: NSGs in this module don't support associations with subnets or addition of diagnostics.  If those features are required, use the foundation module

# v1.4.0
* contribution from joseph.m.janhonen@accenture.com
* added support for explicit subnet ids when creating storage account virtual network rules

# v1.3.3
* bug fixes for storage account network rules

# v1.3.2
* added fix for new availability_zone attribute on azure load balancers causing bug
* note: you will have to add "availability_zone": "No-Zone" if deploying in a region that does not support zone redundancy
* updated to required terraform >= 1.0.0 and azurem >= 2.64.0

# v1.3.1
* storage account fixes from joseph.m.janhonen@accenture.com

# v1.3.0
* schema enhancements from joseph.m.janhonen@accenture.com
* added additional example to try to demo all features
* replaced storage account logic with equivalent logic from foundation module
* changes to key_vault handling to fix race condition

# v1.2.0
* added support for resources to be created in different region to the resource group they belong to
* This change also appears to resolve a bug with changes to tags on a resource group incorrectly resulting in full teardown and rebuild

# v1.1.0
* Added support for improved secrets handling and keyvault management
* ran terraform fmt -recursive
* added secrets example
* removed skip_provider_registration input variable that was no longer used

# v1.0.3
* Slight change to logic for indentifying nics associated with loadbalancer backend - NIC name no longer required to end in "_nic01" 
* added support for setting "license_type" on VMs
* fixed issue with case mismatch between NIC and VM
* added this CHANGELOG.md file

# v1.0.2
# v1.0.1
# v1.0.0