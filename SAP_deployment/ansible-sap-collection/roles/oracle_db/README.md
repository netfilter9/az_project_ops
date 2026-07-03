# oracle_db
This role installs the base ORACLE software on a VM .

## Overview
The installation and configuration of ORACLE software involves a number of steps (at a high level):

* install required pacakages for specific OS.
* modify sysctl parameters.
* setting environment variable parmanently.
* changing oracle folder permission for instalation.
* nstall ORACLE software
* executing orainstRoot.sh and root.sh file as post installation step.

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.sid|SID of the ORACLE install|yes|
|sap.db.software_version|software version of ORACLE|yes|
|root_dir|root location of media files|no (default location is '/usr/sap')|

### group variables (db)
|variable|info|required?|
|---|---|---|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - oracle-db
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenarios/azure/scenario34/ansible/inventory)

## Checks
To validate that ORACLE is up and running, you can run the following command:

```bash
su - ora<sap.db.sid>
sqlplus /as sysdba
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-133