# sybase-hadr
This role sets up the sybase HADR configuration on primary and comapnion servers.

## Overview
The installation and configuration of sybase HADR involves a number of steps (at a high level):

* Create the response file.
* unzip the setup file.
* run the setup file for data movement configuration.
* unlock the sa user.
* run the setuphadr with primary response file in primary server.
* run the setuphadr with companion response file in companion server.
* add the DR_ADMIN entry in securestore.

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|root_dir|root directory where we are putting our media and params file|no (By Default it will take '/usr/sap')|
|passwords.systemdb|password for db user|yes|
|sap.db.sid|db sid for installation directory|yes|
|sap.db.sybase_ocs|sybase ocs version (default OCS-16_0)|no|
|sap.db.sybase_ase|ase version (default ASE-16_0)|no|
|server_type|the server would be either primary or companion server|yes ( value could be 'primary' or 'compnaion')|
|primary_virtual_hostname|the hostname of the primary sybase instnace|yes|
|secondary_virtual_hostname|the hostname of the secondary sybase instnace|yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sybase-hadr
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


* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1397

