# create_tenant
This role creates additional tenants on a HANA DB

## Overview
This role creates additional tenants on a HANA DB

## Role variables
The variable to be used within this role defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.system |password for the tenant DB |yes|
|sap.instance_numbers.db | instance no of the master HANA DB |yes|
|sap.db.tenants| list of tenants which will be created |yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - create-tenant
```
## Example inventory
See: [Examples Repo]


## Checks
To validate that the tenant database is created:
```bash
sapcontrol -nr <instance_number> -function GetProcessList
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-455
