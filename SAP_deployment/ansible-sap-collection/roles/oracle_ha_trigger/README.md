# Oracle_ha_trigger
This role does:

1. update the tnsnames file on primary database server.
2. create the database trigger on primary database server.

## Requirements:

 The Pre-requisites for this role are:

 1. oracle db is to be installed on primary db server.
 2. DG configuration should be done on primary db server.


## Overview
Example playbook:
```yaml
---
# This forces a gather facts across all hosts
- hosts: all

# performing tasks on database server(i.e. tnsnames file update and database trigger creation)
- hosts: db
  roles:
    - oracle-ha-trigger

```

## Role variables:
The variables to be used within this role are to be specified at group_vars level exclusively in all.yml and db.yml .

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.sid|SID of sap install|yes|
|sap.db.sid|SID of the database install|yes|
|sap.db.installation_user|User of database install|yes|
|sap.db.software_version|Software version of Database install|yes|
|passwords.master|master password for oracle database install|yes|


### group variables (db)
|variable|info|required?|
|---|---|---|
|port|Port for oracle database install|yes|
|dbnode1|Reference for the first database node|yes(as the process is done on primary database server)|
|dbnode2|Reference for the second database node|yes|
|db_primary_hostname|secondary or virtual hostname for Primary database|No|
|db_secondary_hostname|secondary or virtual hostname for Secondary database|No|



## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/playbooks/10_connectivity_setup.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/inventory)


## Checks

1. check the updated tnsnames file at: 
```oracle 
/sapmnt/NW1/profile/oracle/tnsnames.ora 
```

2. check the database trigger is created:
```sqlplus prompt

select trigger_name from user_triggers where trigger_name=<trigger name>
```

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1549

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

## References
[Cloud Builder Developer Team design]
