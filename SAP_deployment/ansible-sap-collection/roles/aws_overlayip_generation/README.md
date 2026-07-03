# aws_overlayip_generation
This role modifies hostfile with the overlayIPs in HA Scenario for AWS platform

## Overview
This role adds overlayIP with respective hostname in hostfile for AWS platform

## Role variables
The variable to be used within this role defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.logical_hosts.ascs.hostname |virtual hostname of ascs in HA Scenario|yes|
|sap.logical_hosts.ers.hostname |virtual hostname of ers in HA Scenario |yes|
|sap.logical_hosts.db.hostname |virtual hostname of db in HA Scenario |yes|
|ascs_overlay_ip |overlay ip of ascs |yes|
|db_overlay_ip | overlay ip of db |yes|
|ers_overlay_ip | overlay ip of ers |yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - aws-overlayip-generation
```
## Example inventory
See: [Examples Repo]


## Checks
To validate that the overlay IP entries has been added:
```bash
cat /etc/hosts
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1244
