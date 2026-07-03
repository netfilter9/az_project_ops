# sybase-fault-manager
This role installs sybase db fault manager in ascs machine. It acts as a fencing agent for primary and companion sybase server.

## Overview
The installation and configuration of sybase post task involves a number of steps (at a high level):

* create the file SYBHA_INST.PFL for fault manager configuration
* passing host agent id and password
* install sybdbfm in the server where ascs instance is running
* restart the ascs instance

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|role|the role of the server|yes|
|sap.db.sid|db sid for installation directory|yes|
|passwords.sapadm|password for sapadm user|yes|
|sap.instance_numbers.ascs|instance number for the ascs instance|yes|
|primary_virtual_hostname|the hostname of the primary sybase instnace|yes|
|secondary_virtual_hostname|the hostname of the secondary sybase instnace|yes|
|sap.logical_hosts.ascs.hostname|virtual hostname for ascs|yes|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sybase-fault-manager
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/example-sap/browse/golden_scenarios/azure/scenario106/ansible/inventory)

## Checks
To validate that sybase is installed, you can run the following command(installation folders should be created). Login to the database and check the auditdb and cmsdb :
```bash
cd /sybase/SID
isql -S SID -U sa -P PWD
sp_helpdb
go
```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]


* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1399

