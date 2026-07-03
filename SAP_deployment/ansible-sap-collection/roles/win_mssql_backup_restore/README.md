# win-mssql-backup-restore

This role performs the SQL backup restore on the windows VM.

# Overview

Pre-requisites for this role:

1. SQL software should be installed in the system.
2. Backup files should be present.
3. Source and target SID should be defined.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: mssql
  gather_facts: yes
  roles:
    - win-mssql-backup-restore
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|sap.sid|SID of the target system|yes|
|sap.source_sid|SID of the source system|yes|
|sap.source_datacount|Number of the data folders from source backup|yes|
|sap.data_drive|MSSQL data drive|yes|
|sap.log_drive|MSSQL log drive|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New role to be added for windows backup restore

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1580


