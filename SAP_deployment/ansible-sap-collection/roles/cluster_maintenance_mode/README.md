# cluster_maintenance_mode
This role works with the maintenance mode of a cluster configuration .

## Overview
This role will bring the cluster under maintenance mode and also bring out of maintenance mode.

## Role variables
The variables to be used within this role are at playbook level.

### playbook variables (common)
|variable|info|required?|
|---|---|---|
|maintenance_mode|maintenance_mode is true (keeping under maintenance mode) or false (bringing out of maintenance mode)|no (dafault value is 'false')|


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