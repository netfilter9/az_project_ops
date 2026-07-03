# oel_prereqs
This role installs some packages for OEL os on a VM .

## Overview
The installation of packages involves a number of steps (at a high level):

* install required pacakages for specific OS.

## Role variables
There are no role variables used.

### group variables (all)
|variable|info|required?|
|---|---|---|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - oel-prereqs
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenarios/azure/scenario34/ansible/inventory)

## Checks
To validate that ORACLE is up and running, you can run the following command:

```bash
su - ora<sap.db.sid>
sqlplus /as sysdba
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* Changing the name of the task pacakges to packages.
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-964