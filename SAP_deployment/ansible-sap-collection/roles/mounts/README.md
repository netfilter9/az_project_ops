# mounts
This role initialises the mount the mount points in /etc/fstab or /etc/auto.direct.

## Overview
There are no specific pre-requisites for this role, however, it is assumed that the source is already present.
1. Creating the mount path folders in server.
2. Populating the /etc/fstab file as per the requirement and mount the mount paths.
3. Populating the /etc/auto.direct file as per the requirement and restart the autofs service to auto mount path.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|mounts|an array of mount pounts to be created|yes|
|mounts[loopindex].source|name of the source|yes|
|mounts[loopindex].path|name of the mount path|yes| 
|mounts[loopindex].use_autofs|approach of the mount paths to be mounted either in fstab or autofs|no (dafaults to associated 'fstab' approach), for autofs approach we need to pass 'use_autofs' boolean as 'true'|
|mounts[loopindex].mode|permission of mount path|no (defaults to associated "755" value)| 
|mounts[loopindex].fstype|type of the fstype|no (defaults to associated "nfs" value)|
|mounts[loopindex].opts|mount options|no (defaults to associated "nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev" value for 'fstab' entry and defaults to associated "-nfsvers=4.1,nobind,sec=sys" value for 'autofs' entry)|
|mounts[loopindex].state|state of the mount i.e. mounted or unmounted |no (defaults to associated "mounted" value)|
|default_mount_state|state of the mount i.e. mounted or unmounted |no (defaults to associated "mounted" value)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/scenario17/ansible/playbooks/02_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/scenario17/ansible/inventory)

## Checks
If nfs_mount = nfs, we need to validate the below:
```bash
check the df -h output. 
cat /etc/fstab
```

If nfs_mount = autofs, we need to validate the below:
```bash
check the df -h output. 
cat /etc/auto.direct
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Modifying the code to ensure that autofs.yml should not be executed unless required. Adding condition in main.yml.

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-73
