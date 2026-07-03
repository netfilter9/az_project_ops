# dg_data_sync

This role perform the data-sync between the primary and secondary database.

# Overview

Pre-requisites for dg data sync:

1. Both the databases should be up.
2. All the log files should be emptied on secondary db.
3. Listener and tnsnames files should be updated on both dbs.
4. startup nomount in secondary db and start-stop the listener.
5. Oracle installation user--- default: 'oracle'
6. Database db user--- default: 'sysdba'
7. Master Password

An example playbook for dg-data-sync may look like this:

```yaml

- name: data sync
  hosts: servers
  gather_facts: yes
  roles:
    - dg-data-sync
```

## Role variables
The variables required are defined at group_vars at db level

### group variables (common)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|oracle database installation default user|no|
|sap.db.db_user|default database user|no|
|dbnode1|primary database|yes|
|dbnode2|secondary database|yes|
|root_dir|specified root directory|yes
|sap.db.sid|database sid|yes|
|sap.db.software_version|database software version|yes|
|primary_instance_ch|character representing primary db instance|yes|
|secondary_instance_ch|character representing secondary db instance|yes|
|passwords.sys_primary|password of primary db for rman login|yes|
|passwords.sys_secondary|password of secondary db for rman login|yes|

## Checks

To validate that dg-data-sync has run successfully, check the status of flashback in secondary database(to be 'on').

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1542

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)