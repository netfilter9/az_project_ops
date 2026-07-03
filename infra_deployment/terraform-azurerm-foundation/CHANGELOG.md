# v5.7.0
* contribution from thomas.hafermalz@accenture.com
* updates to firewalls policy for vwan setup -> idps, dns, threat_intelligence_mode; zones for vwan firewall
* tested with terraform v1.1.9 and azurerm provider v3.3.0
# v5.6.1
* contribution from vadim.petiul@accenture.com
* fixed the name of the data lake path resource
* tested with terraform v1.1.9 and azurerm provider v3.5.0

# v5.6.0
* contribution from steven.t.urwin@accenture.com
* updates to firewalls and virtual wans
* tested with terraform v1.1.9 and azurerm provider v3.3.0

# v5.5.0
* contribution from vadim.petiul@accenture.com
* added queue, table, and data lake gen2 services, and additional storage account settings to storage accounts
* minor bug fix for storage accounts, added tag support for storage accounts
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v5.4.0
* contribution from steven.t.urwin@accenture.com
* improved diagnostics support for storage accounts to include storage sub components
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v5.3.0
* contribution from steven.t.urwin@accenture.com
* added diagnostics support to storage accounts
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v5.2.0
* contribution from steven.t.urwin@accenture.com
* added blob and container retention support to storage accounts
* tested with terraform v1.1.7 and azurerm provider v3.0.2

# v5.1.0
* contribution from thomas.hafermalz@accentre.com
* switch on firewall module to deploy a firewall to a virtual hub
* tested with terraform v1.1.2 and azurerm provider v3.0.2

# v5.0.1
* fixed "bug" where storage accounts allowed public access by default following updates to azure provider defaults
* tested with terraform v1.1.7 and azurerm provider v3.0.1

# v5.0.0
* WARNING: Interface breaking changes
* various updates to experimental AKS code
* changes to zone and sku handling in firewalls
* tweak to handling of network watcher flow logs for security groups along with additon of name and location
* contribution from steven.t.urwin@accenture.com
* major upgrade to Azure provider version
* tested with terraform v1.1.7 and azurerm provider v3.0.1

# v4.0.1
* contribution from Petiul, Vadim <vadim.petiul@accenture.com>
* minor updates to the keyvault
* tested with terraform v1.1.4 and azurerm provider v2.93.1

# v4.0.0
* contribution from steven.t.urwin@accentre.com
* interface breaking change update to traffic manager endpoints (removing deprecated feature) 
* tested with terraform v1.1.4 and azurerm provider v2.93.1

# v3.5.1
* contribution from Petiul, Vadim <vadim.petiul@accenture.com>
* minor tweak to private_endpoints to all them to be defined in a different region to their resource group
* tested with terraform v1.1.4 and azurerm provider v2.93.1

# v3.5.0
* added support for private end points and access policies on key vaults  
* tested with terraform v1.1.0 and azurerm provider v2.89.0

# v3.4.0
* added support for azurerm_traffic_manager_profile and azurerm_traffic_manager_endpoint
* tested with terraform v1.0.11 and azurerm provider v2.88.0

# v3.3.0
* submission from Petiul, Vadim <vadim.petiul@accenture.com> and Bethalam, Anil <anil.bethalam@accenture.com>
* enhancement to key vaults to allow acls and other control params

# v3.2.4
* updated code to avoid doing data lookup on resources created during deployment - resolve issues with cascading rebuilds
* tested with terraform v1.0.8 and azurerm provider v2.80.0

# v3.2.3
* updated code to resolve storage deprecation warning
* ran teraform fmt
* updated minimum provider version to 2.78.0
* NOTE: provider version 2.79.0 is broken
* tested with azurerm provider 2.78.0 and terraform v1.0.8

# v3.2.2
* bugfix for route tables - unable to specify next hop ip address for default route when type is VirtualAppliance

# v3.2.1
* added support for ddos on network resources where ddos defined in secondary subscription (using explicit id reference)

# v3.2.0
* added initial support for ddos on network resources

# v3.1.1
* Hot fix from talking to Anil
* added tags to some network resources
* fixed race conditions between subnets and nsg subnet associations
* KNOWN ISSUE: Changing tags outside of terraform causes a lot of things to be destroyed and recreated - please don't do this 

# v3.1.0
* Contribution from Bryan Long <bryan.m.long@avanade.com>
* added support for ASGs in NSG rules

# v3.0.0
* WARNING: Interface breaking change
* updated handling of networks/subnets, network security group and route tables to inprove handling of sub-objects
* by default, we now create security rules and routes as independent object rather than declaring inline
* also updated handling of subnets and subnets associations across all object to behave consistently
* updates to storage account to ensure that handling on inline rules is consistent with other inline objects 
* KNOWN ISSUE: Updating the network block results in a large number of resources being destroyed and redeployed.  This existed in the old code too but still needs investigating.

# v2.1.0
* tweak for network security groups relating to 

# v2.0.0
* contributions from Devin Lusby <devin.m.lusby@avanade.com>
* added support for aks
* changed to dns zone handling of networks - interface breaking

# v1.2.0
* Updated storage support for rules and private endpoints (interface breaking change for storage)
* Fixed cyclic dependency issue with diagnostics, storage and networks
* updated provider block to support v0.15 expecations
* added option "secrets" input for later use

Outstanding issues in v1.2.0: 
* still have to run apply twice on full build due to unresolved storage/diagnostics race condition
* adding storage account rules with create_rules_as_resources set to "true" isn't working correctly