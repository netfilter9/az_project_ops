# Enable_fast_start:
This role does:

1. Starts the primary observer server as master.
2. Starts the secondary observer server as secondary.
3. Enable fast start failover on primary database server.

## Requirements:

 The Pre-requisites for this role are:

 1. oracle db is to be installed on primary db server.
 2. DG configuration should be done on primary db server.
 3. Observer setup is done on primary and secondary observer server.

## Overview
Example playbook:
```yaml
---
# This forces a gather facts across all hosts
- hosts: all

# Starts both primary and secondary observer as master and standby
- hosts: observer
  roles:
  - enable-fast-start

# Enables fast start failover process on primary database server
- hosts: "{{ groups['db'][0] }}" 
  roles:
    - enable-fast-start
```

## Role variables:
The variables to be used within this role are to be specified at group_vars level exclusively in all.yml, db.yml and observer.yml.

### group variables (all)
|variable|info|required?|
|---|---|---|
|observer_sid|SID of observer |yes|
|sap.db.sid|SID of the database install|yes|
|sap.db.installation_user|Database installation user|yes|
|sap.db.software_version|Software version of Database install|yes|
|passwords.master|master password for oracle database install|yes|


### group variables (db)
|variable|info|required?|
|---|---|---|
|primary_instance_ch|Unique identification character for primary db|yes|
|secondary_instance_ch|Unique identification character for secondary db|yes|
|obsnode1|Reference for the first observer node|yes|
|obsnode2|Reference for the second observer node|yes|
|dbnode1|Reference for the first database node|yes|



## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/playbooks/10_connectivity_setup.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/inventory)


## Checks

1. check the observer is started and setup as master and secondary.
```dgmgrl prompt
show observer
```

2. To validate fast start failover process is up:
```dgmgrl prompt
show fast_start failover

OR

show configuration
```

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1547

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Start up the primary and secondary observer server as master and standby.
2. Enabling the fast_start failover process in primary database.

## References
[Cloud Builder Developer Team design]
