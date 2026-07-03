# cluster-maintenance-mode
This role installs dataprovider in aws

## Overview
This role installs dataprovider in aws.

## Role variables
The variables to be used within this role are at playbook level.

### playbook variables (common)
|variable|info|required?|
|---|---|---|
|connectivity|connectivity is yes https download and if connectivity is no s3 bucket download|yes|
|suse_dataprovider_url|suse https dataprovider url |yes|
|rhel_dataprovider_url|rhel https dataprovider url|yes|
|suse_gpgkey_url|suse gpgkey url|yes|
|dataprovider_suse|suse dataprovider package name |no|
|dataprovider_rhel|rhel dataprovider package name|no|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenario/azure/scenario95/ansible/playbooks/06_hana_load.yml)

## Checks
To validate that the cluster is under maintenance mode or not, you can run the following command from the first cluster node:
```bash
sudo crm_mon
```


## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]


## Reference
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-997