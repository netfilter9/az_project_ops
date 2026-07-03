# cloud_checker_checks
This role is for checking the status of vm's post SAP installation.

## Overview
The cloud checker involves a number of steps:

* db-checks
* os-checks
* infra-checks
* platform-checks
* ABAP-checks

## Role variables
The variables to be used within this role are all defined at group_vars and host_vars level.

## Example playbook
```yaml
---
- hosts: all
  roles:
    - cloud_checker_checks
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1631
