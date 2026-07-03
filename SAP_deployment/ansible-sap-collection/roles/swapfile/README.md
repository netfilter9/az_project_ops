# swapfile
This role creates the swapfile in machine.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|platform|cloud platform needs to be mentioned|yes|
|swapfile_size|size of swapfile needs to be created|no (defaults to associated "2052" value)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc56-s41909abap-hana-2tier-nonha-anf/ansible/playbooks/02_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc56-s41909abap-hana-2tier-nonha-anf/ansible/inventory)

## Checks
```Check with the command...
free -g | grep Swap
```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)