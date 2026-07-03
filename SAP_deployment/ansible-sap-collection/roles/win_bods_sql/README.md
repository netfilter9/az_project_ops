# win_bods_sql

This role manages to create database,DSN and grants permission to sql server authentication for BODS.

## Overview
The installation involves a number of steps :

* Creating database
* creating DSN
* Authorizing server role([NT AUTHORITY\SYSTEM])
* granting permission to sql server authentication
* creating sql login details
* selecting sysadmin server role
* mapping users in sql server

## Example playbook

```yaml
---

- name: windows bods install
  hosts: std
  roles:
    - win_bods_sql
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/examples-sap//browse/golden_scenarios/azure/scenario124/ansible/inventory)

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1704
