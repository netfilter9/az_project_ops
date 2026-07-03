# win-dns-record

This role performs the addition of VM entries to the DNS server.

# Overview

Pre-requisites for windows dns record:

1. FQDN details need to be provided in windows.yml
2. domain credentials with proper access to add the VMs to be mentioned in windows.yml.
3. domain controller to be defined under domain_controllers server group.
4. List of entries to be passed in all.yml under LB_config.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: domain_controllers
  gather_facts: yes
  roles:
    - win-dns-record
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|lb_config.name|Virtual host name associated with the LB IP|yes|
|lb_config.value|LB IP|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the VM is domain joined, you can run the following command in control node:

```powershell
Get-DnsServerResourceRecord -ZoneName domain.fqdn -RRType A
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New Role to be created as win-dns-record

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-483


