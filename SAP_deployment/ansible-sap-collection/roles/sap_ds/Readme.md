# sap-ds
This role installs the ds software on a VM .

## Overview
The installation and configuration of DS software involves a number of steps (at a high level):

* creating ds config file
* Install DS software

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.master|master password for HANA install|yes|
|passwords.system|password for system user|yes|
|admin_user|username for the installation|yes|
|sap.instance_numbers.db| db instance number for the dsrepodbport|yes|
|sap.logical_hosts.db.hostname| host name of the db server(default ansible_hostname)|no|
|sap.db.type| db type used for installation HANA/SYBASE(default HANA)|no|
|sap.db.sybase_ocs| ocs version of sybase(default OCS-16_0)|no|
|root_dir|directory for sap implementation|no, default value is '/usr/sap'|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sap-ds
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario40/ansible/inventory)

## Checks
To validate that DS is installed, open browser and hit http://<bodsserverip>:8080/BOE/CMC
You can run the following command(check dataservices folder should be created):
```bash
cd /usr/sap/DataServices
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-408
