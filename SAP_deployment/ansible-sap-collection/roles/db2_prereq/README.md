# db2_prereq
This role installs some packages for DB2 database installation on a VM.

## Overview
The installation of packages involves a number of steps:

* Determines the Linux distribution level.
* install required pacakages for specific OS.
* Commenting the port 5912.

## Role variables
The variable to be used within this role defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|passwords.siddb|password for the DB|yes|

## Example playbook
```yaml
---
- hosts: std
  roles:
    - db2-prereq
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenarios/azure/scenario129/ansible/inventory)

## Code Update 
|Type of change - interface breaking or minor |Reason for code update|Author|Date|
|---|---|---|---|
|minor|added the package resource-agents for db2_aws RedHat OS type|Apoorva|-|
|minor|added the package libncurses5 for db2_azure SUSE OS type|Apoorva|21st Nov 2022|

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* New role to be added for DB2 database installation prerequisites.
