# filesystem_lvm
This role initialises the file system on a provisioned VM using volume groups and logical volumes

## Overview
There are no specific pre-requisites for this role, however, it is assumed that the VM has been provisioned with some attached disks.

Note: The disk reference format will change depending on the cloud platform used.

## Role variables
The variables to be used within this role are all defined at group level (assuming that you want all servers in a group to have the same disk configuration)

### group variables (common)
|variable|info|required?|
|---|---|---|
|volume_groups|an array of volume groups to be created|yes|
|volume_groups[group].pvs|comma separated list of disk references (physical volumes)|yes|
|volume_groups[group].vg|name for the volume group|no (defaults to associated "ref" value)| 
|volume_groups[group].lv|name for the logical volumes|no (defaults to associated "ref" value)|
|volume_groups[group].size|amount of space to allocation (actual size or percentage)|no (defaults to `100%VG`)|
|volume_groups[group].fstype|filesystem type to be used when formatting|no (defaults to `xfs`)|
|volume_groups[group].opts|options type to be used when mounting|no (defaults to `defaults`)|
|volume_groups[group].ref|unique reference for the volume|yes| 
|volume_groups[group].mount|defines the mount point for the logical volume|no (only required if filesystem needs to be mounted)|
|volume_groups[group].mode|defines the permissions on the created mount folder|no (defaults to `0755`)|
|volume_groups[group].shrink|Shrink if current size is higher than size requested for the folder|no (defaults to `yes`)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/playbooks/05_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/scenario17/ansible/inventory)

## Checks
To validate that filesystems have been created and mounted:
```bash
df -h
```

Output will vary depending on the configured groups and volumes

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Adding 'opts' attribute in mount module as it can be taken as client input otherwise by default it should pick 'defaults'
2. Rename the role to 'filesystem-lvm' as per TODO.md . 
2. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-120
