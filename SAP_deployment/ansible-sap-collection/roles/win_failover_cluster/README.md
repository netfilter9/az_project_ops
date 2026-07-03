# win-failover-cluster

This role perform the Cluster creation for HA on windows.

# Overview

Pre-requisites for windows cluster role:

1. Cluster details to be specified.
2. Cluster quoram details to be mentioned.
3. Storage account to be created for quoram creation.
4. Access key to be provided in vault.yml

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: sofs:ascs
  gather_facts: yes
  roles:
    - win-failover-cluster
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|cluster.name|Name of sofs cluster|yes|
|cluster.ip|IP of sofs cluster|yes|
|domain.fqdn|domain name|yes|
|cluster.quorom_storage_account_name|Storage account name for quoram|yes|
|cluster.quorom_storage_account_key|Storage account access key|yes|
|sap.global_hostname|global name for Fileshare|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the Sofs cluster and configurations are completed:

```powershell
Get-Cluster -Name "{{ node }}" -ErrorAction SilentlyContinue
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Conditions to be updated for cluster role. 

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-155

