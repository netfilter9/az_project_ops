# user-setup
This role initialises the creation of user explicitly.

## Requirements
There are no specific pre-requisites for this role, however, it is assumed that the groups must be created already. By default sapsys groups should be existing.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|usersetup|an array of users to be created|yes|
|usersetup[loopindex].name|name of the user|yes|
|usersetup[loopindex].uid|user id of the user|yes| 
|usersetup[loopindex].shell|shell of the user|no (defaults to associated "/bin/bash" value)|
|usersetup[loopindex].password|password of the user|yes|
|usersetup[loopindex].group|group of the user|yes|
|usersetup[loopindex].groups|secondary group of the user|no (defaults to associated null value)|
|usersetup[loopindex].state|state of the user|no (defaults to associated "present" value)|
|usersetup[loopindex].sudo|sudoers access to the user|no (defaults to associated "false" value)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/playbooks/02_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/inventory)

## Checks
To validate that user has been created:
```bash
cat /etc/passwd | grep "username"
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Adding the user in secondary group.

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-149