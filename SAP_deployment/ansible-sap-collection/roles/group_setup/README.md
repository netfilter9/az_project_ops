# group_setup
This role initialises the creation of group explicitly.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|groupsetup|an array of users to be created|yes|
|groupsetup[loopindex].name|name of the group|yes|
|groupsetup[loopindex].gid|group id of the gorup|yes| 
|groupsetup[loopindex].state|state of the group|no (defaults to associated "present" value)|


## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/playbooks/02_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/inventory)

## Checks
To validate that user has been created:
```bash
cat /etc/group | grep "groupname"
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)