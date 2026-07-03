# win-domain-join

This role perform the domain join on the windows VMs.

# Overview

Pre-requisites for windows domain join:

1. FQDN details need to be provided in windows.yml
2. domain credentials with proper access to add the VMs to be mentioned in windows.yml.
3. VMs to be defined under windows_workgroup in host file.
4. OU path is required to perform domain join on the target servers.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: windows_workgroup
  gather_facts: yes
  roles:
    - win-domain-join
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|local_admin username|local admin of the VM|yes|
|local_admin password|local admin password of the VM|yes|
|FQDN|domain name|yes|
|domain controller|Domain controller where the domain is hosted|yes|
|domain username|domain admin username|yes|
|domain username password|domain admin password|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the VM is domain joined, you can run the following command in control node:

```bash
ansible (VMname) -m win_ping
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Role name changed to win-domain-join
2. Removed the ntp component 

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-117


