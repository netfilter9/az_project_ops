# domain_join

This role perform the domain join on the Linux VMs.

# Overview

Pre-requisites for windows domain join:

1. FQDN details need to be provided in all.yml
2. domain credentials with proper access to add the VMs to be mentioned in all.yml.
4. OU path is required to perform domain join on the target servers.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: servers
  gather_facts: yes
  roles:
    - domain-join
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|domain.fqdn|domain name|yes|
|domain.domain_controller|Domain controller where the domain is hosted|yes|
|domain.controllers|Domain controller where the domain is hosted|yes|
|domain.username|domain admin username|yes|
|domain.password|domain admin password|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the VM is domain joined, you can run the following command in the VM:

```bash
realm status
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Role name changed to domain-join

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1101


