# aws_setup_profile_cluster
This role Setting up Profile in HA Scenario for AWS platform

## Overview
This role adds region details in /root/.aws/config file for AWS VMs

## Role variables
The variable to be used within this role defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|region |region of all VMs|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - aws-setup-profile-cluster
```
## Example inventory
See: [Examples Repo]


## Checks
To validate that the :
```bash

```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1247
