# hana_users
This role creates additional users on a HANA DB

## Overview
This role creates additional users on a HANA DB

## Role variables
The variable to be used within this role defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.system |password for the tenant DB |yes|
|sap.instance_numbers.db | instance no of the master HANA DB |yes|
|sap.db.users| list of users which will be created |yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - hana-users
```
## Example inventory
See: [Examples Repo]


## Checks
To validate that the users are created:
```bash
isql <DSN name> <user name> <password>
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-694 