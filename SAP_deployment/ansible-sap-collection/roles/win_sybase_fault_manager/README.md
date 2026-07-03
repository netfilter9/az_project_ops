# win-sybase-fault-manager

This role perform the fault manager installation for sybase windows HA.

# Steps:

1. sybdbfm is installed.
2. SYBHA profile to be edited as per standard.

An example playbook for win domain join may look like this:

```yaml

- name: install fault manager
  hosts: mssql
  gather_facts: yes
  roles:
    - win-sybase-fault-manager
```

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/users/anisha.baskey/repos/examples-sap/browse/golden_scenarios/azure/scenario136/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/users/anisha.baskey/repos/examples-sap/browse/golden_scenarios/azure/scenario136/ansible/inventory)

## Checks
To validate that the SQL availabilty group configurations are completed:

```cmd
sybdbfm list
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New role to be created for fault manager installation.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1460


