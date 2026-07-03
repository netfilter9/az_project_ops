# win-firewall

This role adds inbounds ports on the VM firewall.

# Overview

Pre-requisites for firewall:

1. ports needs to be defined as per the instance number.

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|mssql_params.install.firewall.profile|firewall profile|yes|
|mssql_params.install.firewall.ports|firewall ports|yes|

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: pas
  gather_facts: yes
  roles:
    - win-firewall
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

1. New Role to be created as win-firewall.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1211


