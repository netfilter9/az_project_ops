# dg_configuration

This role sets the data guard broker process to start and also sets the properties of primary database using DGMGRL commands.

# Overview

Pre-requisites for dg configuration :

1. Both the databases should be in sync.
2. Secondary database flashback should be on.
3. Oracle installation user--- default: 'oracle'
4. Database db user--- default: 'sysdba'
5. Dgmgrl user--- default: 'sys'
6. Master Password

An example playbook for dg-configuration may look like this:

```yaml

- name: data sync
  hosts: servers
  gather_facts: yes
  roles:
    - dg-configuration
```

## Role variables
The variables required are defined at group_vars at db level

### group variables (common)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|oracle database installation default user|no|
|sap.db.db_user|default database user|no|
|sap.db.dgmgrl_user|default database user|no|
|dbnode1|primary database|yes|
|dbnode2|secondary database|yes|
|root_dir|specified root directory|yes
|sap.db.sid|database sid|yes|
|sap.db.software_version|database software version|yes|
|primary_instance_ch|character representing primary db instance|yes|
|secondary_instance_ch|character representing secondary db instance|yes|
|port|port for oracle db|no|
|passwords.master|password for rman login|yes|
|db_primary_hostname|secondary or virtual hostname for Primary database|No|
|db_secondary_hostname|secondary or virtual hostname for Secondary database|No|

## Checks

To validate that dg-data-sync has run successfully, switch the logfiles using 'alter system switch logfiles' on db1 and see the change in number of log files in oracle/NW1/oraarch_standby on db2. Also use command show configuration to see the database roles which one is primary and which is standby.

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1544

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)