# dg_config_prereq

This role configures primary and secondary oracle database before synching.

# Overview

Pre-requisites

1. Oracle installation user--- default: 'oracle'
2. Database db user--- default: 'sysdba'
3. Master password 

An example playbook for dg-config-prereq may look like this:

```yaml

- name: prerequisites for data sync
  hosts: servers
  gather_facts: yes
  roles:
    - dg-config-prereqs
```

## Role variables
The variables required are defined at group_vars at db level

### group variables (common)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|oracle database installation default user|no|
|sap.db.db_user|default database user|no|
|dbnode1|primary database|yes|
|root_dir|specified root directory|yes
|sap.db.sid|database sid|yes|
|logfile_size|size of logfile|yes|
|port|port for oracle db|no|
|instance_ch|character representing db instance|yes|
|no_of_standby_logs|number of standby logs to be created|Yes|
|db_primary_hostname|secondary or virtual hostname for Primary database|No|
|db_secondary_hostname|secondary or virtual hostname for Secondary database|No|


## Checks

To validate that dg-config-prereq has run successfully, check the standby_redo--.log files created in /oracle/NW1/origlogA in primary database and status of flasback in secondaru database(to be 'on').

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1535

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)