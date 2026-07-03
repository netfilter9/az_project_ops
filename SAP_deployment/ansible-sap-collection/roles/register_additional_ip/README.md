# register-additional-ip
This role is being used for virtual ip modification in ifcfg-eth file.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|virtual_ip|virtual ip needs to be added|yes|
|netmask|netmask of the vnet of the virtual ip|no (defaults to associated "255.255.255.0" value)|


## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenario/azure/scenario34/ansible/playbooks/02_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenario/azure/scenario34/ansible/inventory)

## Checks
To validate that user has been created:
```bash
cat /etc/sysconfig/network/ifcfg-eth0
or
cat /etc/sysconfig/network-scripts/ifcfg-eth0
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-136
* changing the role to fix secondary ip after reboot