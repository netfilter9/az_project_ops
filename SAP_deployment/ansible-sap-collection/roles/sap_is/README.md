# sap-ips
This role installs the IS software on a VM .

## Overview
The installation and configuration of IS software involves a number of steps (at a high level):

* install required pacakages for specific OS.
* Update user profile
* Install HDBClient software if required
* creating IS config file
* Install IS software

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.clusterkey|cluster key for IS install|yes|
|passwords.master|master password for installation|yes|
|passwords.systemdb|password for db install|yes|
|passwords.cmsadmin|password for cms admin|yes|
|passwords.lcm|password for lcm user|yes|
|admin_user|username for the installation|yes|
|sap.instance_numbers.db| db instance number for the dsrepodbport|yes|
|sap.logical_hosts.db.hostname| host name of the db server(default ansible_hostname)|no|
|sap.db.type| db type used for installation HANA/SYBASE|yes|
|sap.db.sid| sid used for installation directory|yes|
|sap.db.sybase_ocs|ocs version used for sybase(default OCS-16_0)|no|
|root_dir|directory for sap implementation|no, default value is '/usr/sap'|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sap_is
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario40/ansible/inventory)

## Checks
To validate that IPS is installed, you can run the following command(check sap_bobj, setup and InstallData folders should be created). Check http://myserverip:8080/BOE/CMC is up and running:
```bash
cd /usr/sap/SID/IS
```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-408
