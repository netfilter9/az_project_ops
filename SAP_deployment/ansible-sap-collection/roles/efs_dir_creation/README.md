# efs_dir_creation
This role creats directory inside EFS

## Overview
1. mounting with EFS vol
2. Creating the mount source path inside EFS vol
3. umounting

## Role variables
The variables to be used within this role are all defined at group_vars 

### group variables (common)
|variable|info|required?|
|---|---|---|
|sapmnt_efs_dns_name|name of EFS |yes| 
|efs_mount_option|mount option for EFS vol |yes| 
|efs_directory|loop variable consists of the mount source path inside EFS |yes| 

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenario/aws/scenario123/ansible/playbooks/02_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/aws/scenario123/ansible/inventory)

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
