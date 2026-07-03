# win-sql-always-on

This role perform the SQL always ON configurations for windows HA.
Steps:
1. Required services are enabled for always ON configuration.
2. availabilty groups are created.
3. Backup to be created in Primary DB server.
4. joins secondary DB to availabilty group and restore the database.

# Overview

Pre-requisites for SQL always ON configurations role:

1. avaiabilty groups details to be specified in mssql.yml
2. avaiabilty group replica details to be mentioned in mssql.yml.
3. avaiabilty group listener details to be mentioned in mssql.yml.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: mssql
  gather_facts: yes
  roles:
    - win-sql-always-on
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|cluster.ip|IP of db cluster|yes|
|domain.fqdn|domain name|yes|
|cluster.sqlavailabilityGroup|Availabilty group name for always on service|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the SQL availabilty group configurations are completed:

```powershell
Test-SqlAvailabilityGroup -Path "SQLSERVER:\Sql\Server\InstanceName\AvailabilityGroups\MainAG" -AllowUserPolicies
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. SQL always ON config to be added 

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-624


