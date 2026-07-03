# win-set-probe-port

This role sets the probe ports on ASCS/ERS for windows HA.
Steps:
1. Run powershell probe port script.
2. Set the load balancer probe port to ASCS/ERS vm.

# Overview

Pre-requisites for setting probe port:

1. SAP ASCS component should be pre-install

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: ascs
  gather_facts: yes
  roles:
    - win-set-probe-port
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|sap.instance_numbers|Instance no of ASCS/ERS |yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the SQL availabilty group configurations are completed:

```powershell
ping [loadbalacer frontend ip]
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Probe port setting to be added 

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1382


