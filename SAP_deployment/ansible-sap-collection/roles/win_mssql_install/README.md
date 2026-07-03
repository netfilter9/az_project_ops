# win-mssql-install

This role installs MSSQL software on database server.

# Overview

Pre-requisites for mssql software installation:

1. dsc modules and required .NET Framework to be imported to install software.
2. sql service accounts needs to be created.
3. binary blob path needs to be provided.

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|mssql_params.install.version|sql version|yes|
|mssql_params.install.instance_name|sql version|no|
|mssql_params.install.features|sql feature|no|
|mssql_params.install.collation|sql collation|no|
|mssql_params.downloads.url|binary url|yes|
|mssql_params.downloads.token_ref|SAS token|yes|
|mssql_params.downloads.dest|destination path|yes|

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: pas
  gather_facts: yes
  roles:
    - win-mssqlclient-install
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

1. New Role to be created as win-mssql-install

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1211


