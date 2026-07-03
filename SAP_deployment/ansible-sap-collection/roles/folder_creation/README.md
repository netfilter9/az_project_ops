# folder_creation
This role is being used for folder creation.

## Requirements
There are no specific pre-requisites for this role, user and group should be present already before creation the directory.

## Role variables
The variables to be used within this role are all defined at host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|folders|an array of directories to be created|yes|
|folders[loopindex].path|name of the directory path|yes|
|folders[loopindex].owner|name of the owner of the directory|yes| 
|folders[loopindex].group|name of the group of the directory|yes|
|folders[loopindex].mode|permission of the directory|no (defaults to associated "755" value)|
|folders[loopindex].attr|attribute of the directory|no (defaults is blank)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/playbooks/02_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/inventory)

## Checks
We can validate the below:
```bash
cd <path>
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)