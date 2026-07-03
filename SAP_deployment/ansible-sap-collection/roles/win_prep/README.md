# win-prep

This role Installs pre-requisites for SAP installation on windows VMs.

# Overview

Pre-requisites for SAP installation on windows VMs:

1. Disables user account control setting.
2. Disbales guest account.
3. Installs DSC modules required for SAP installation. 
4. sets first optical disk drive letter to Z
5. Disable firewall if required.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: all
  gather_facts: yes
  roles:
    - win-prep
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

1. Disable firewall options to be added in this role.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-154


