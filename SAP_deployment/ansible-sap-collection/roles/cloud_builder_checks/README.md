# cloud_builder_checks
This role is for checking the status of vm's (infra check, db check and os check).

## Overview
The cloud builder involves a number of steps:

* db-checks
* os-checks
* infra-checks

## Role variables
The variables to be used within this role are all defined at playbook level.

## Example playbook
```yaml
---
- hosts: all
  roles:
    - cloud_builder_checks
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1666
