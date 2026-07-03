# win-ha-prereqs

This role Manages Windows local group membership & disbables firewall.

# Overview

Pre-requisites for windows dns record:

1. FQDN details need to be provided in windows.yml
2. domain username need to be provided in windows.yml

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: ascs:sofs
  gather_facts: yes
  roles:
    - win-ha-prereqs
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|domain.fqdn|domain name|yes|
|domain.username|domain admin username|yes|

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

1. New Role to be created as win-ha-prereqs

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-485


