# sap-ds
This role installs the sybase sdk on a VM .

## Overview
The installation and configuration of sdk software involves a number of steps (at a high level):

* creating sdk config file
* Install SDK software

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|admin_user|username for the installation|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sap-ds
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario40/ansible/inventory)

## Checks
You can run the following command(check installation files are created):
```bash
cd /sybase/SDK
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* create parameter file
* Install SDK software
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-534
