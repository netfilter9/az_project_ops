# sap-ips
This role is use to install packages and set the environment variable.

## Overview
The installation and configuration of package and environment variable (at a high level):

* Installs required pacakages for specific OS.
* Update user profile

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sap_bo_prereq
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario40/ansible/inventory)

## Checks
```bash
cd /usr/sap/SID/IPS
```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-408
