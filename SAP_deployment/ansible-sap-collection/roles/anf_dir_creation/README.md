# anf_dir_creation
This role creats directory inside anf volume

## Overview
1. mounting with anf vol
2. Creating the mount source path inside anf vol
3. umounting

## Role variables
The variables to be used within this role are all defined at group_vars 

### group variables (common)
|variable|info|required?|
|---|---|---|
|anf_vol[loopindex].path|name of path |yes| 
|anf_vol[loopindex].source|source path of anf volume |yes| 
|anf_vol[loopindex].fstype|type of the filesystem |no (defaults to associated "nfs" value)| 
|anf_vol[loopindex].opts|mount options|no (defaults to associated "nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev" value for 'fstab' entry)|
|anf_folders[loopindex].path|name of folder created inside the volume |yes| 
|anf_folders[loopindex].mode|permission of the folder |no (defaults to associated "755" value)| 

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenario/azure/scenario153/ansible/playbooks/02_anf_dir_creation.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/azure/scenario153/ansible/inventory)

## Checks
manually mount again EFS and check for 

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1250
