# Set-fast-start:
This role setup the fast-start-failover property on primary database server.

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

# enable fast start failover process on primary database server.
- hosts: "{{ groups['db'][0] }}" 
  roles:
    - set-fast-start
```

## Role variables:
The variables to be used within this role are to be specified at group_vars level exclusively in all.yml and db.yml.

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.sid|SID of the database install|yes|
|sap.db.installation_user|Database installation user|yes|
|sap.db.software_version|Software version of Database install|yes|
|passwords.master|master password for oracle database install|yes|


### group variables (db)
|variable|info|required?|
|---|---|---|
|primary_instance_ch|Unique identification character for primary db|yes|
|secondary_instance_ch|Unique identification character for secondary db|yes|



## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/playbooks/10_connectivity_setup.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure//ansible/inventory)


## Checks
To validate that fast start failover process is up:
```dgmgrl prompt
show fast_start failover

OR

show configuration
```

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1548

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Enabling the fast_start failover process in primary database.

## References
[Cloud Builder Developer Team design]
