# win-mssqlclient-install

This role installs MSSQL ODBC clinet to connect MSSQL database.

# Overview

Pre-requisites for mssql ODBC client:

1. binary blob path needs to be provided in pas.yml.

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (pas)
|variable|info|required?|
|---|---|---|
|mssql_params.downloads.url|binary url|yes|
|mssql_params.downloads.token_ref|SAS token|yes|
|mssql_params.downloads.dest|destination path|yes|

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: pas
  gather_facts: yes
  roles:
    - win_mssqlclient_install
```

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

1. New Role to be created as win-mssqlclient-install

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1211


