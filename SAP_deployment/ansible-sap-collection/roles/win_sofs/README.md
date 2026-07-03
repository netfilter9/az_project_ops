# win-sofs

This role perform the Scale out file service config for windows HA.
Steps:
1. Enable S2D (ClusterStorageSpacesDirect) feature.
2. Adds scaleout file server role
3. Adds Cluster Scale Out File Server Role
4. Create sapmnt share for windows cluster setup.

# Overview

Pre-requisites for windows Sofs role:

1. Cluster details to be specified in sofs.yml
2. Cluster quoram details to be mentioned in sofs.yml.
3. Storage account to be created for Sofs quoram creation.
4. Access key to be provided in vault.yml

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: sofs
  gather_facts: yes
  roles:
    - win-sofs
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
(Get-ClusterStorageSpacesDirect).State
Get-WindowsFeature FS-FileServer
Test-Path C:\ClusterStorage\SAPSOF
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Global sapmnt share config to be added 

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-448


