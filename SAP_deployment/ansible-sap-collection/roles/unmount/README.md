# mounts
This role  unmount the mount points in /etc/auto.direct and deletes the directory.

## Overview
There are no specific pre-requisites for this role, however, it is assumed that the source is already present.
1. Unmounts the mount path folders in server .
2. Deleting entry from /etc/suto.direct .
3. Restart the autofs service .

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|delete_dir|directory tobe deleted|yes|

## Example playbook
See: [Examples Repo]https://innersource.accenture.com/projects/IASC/repos/examples-sap/browse/golden_scenarios/gcp/scenario157?at=refs%2Fheads%2Fstaging

## Example inventory
See: [Examples Repo]https://innersource.accenture.com/projects/IASC/repos/examples-sap/browse/golden_scenarios/gcp/scenario157?at=refs%2Fheads%2Fstaging

## Checks
check the df -h output. 
cat /etc/auto.direct

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Modifying the code to ensure that autofs.yml should not be executed unless required. Adding condition in main.yml.

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1758
