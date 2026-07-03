# sap-ips
This role installs the sybase software on a VM .

## Overview
The installation and configuration of sybase software involves a number of steps (at a high level):

* install required pacakages for specific OS.
* Update user profile
* creating ase config file
* Install Sybase software
* Update the sybase locales.dat
* Create audit database
* Create cms databse
* Create db users

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.master|master password for db install|yes|
|passwords.admin|password for system user|yes|
|passwords.systemdb|password for db user|yes|
|passwords.cockpittechuser|password for cockpit tech user|yes|
|passwords.selfmanagement|password for self management|yes|
|passwords.sccadmin|password for scc admin |yes|
|passwords.sccuafadmin|password for scc uaf admin |yes|
|passwords.sccrepository|password for scc uaf repository|yes|
|admin_user|username for the installation|yes|
|sap.db.sid|db sid for installation directory|yes|
|sap.logical_hosts.db.hostname|db installation hostname (default hostname)|no|
|sap.db.sybase_ocs|sybase ocs version (default OCS-16_0)|no|
|sap.db.sybase_ase|ase version (default ASE-16_0)|no|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sybase-db
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario40/ansible/inventory)

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

* Install packages libstd*
* Update the user profile 
* create parameter file
* Install sybase software
* Update the language in locales.dat file
* Create sql files for cmsdb, auditdb and users
* Create cms database
* Create audit database
* Create database users

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-147

