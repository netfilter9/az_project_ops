# sybase-post-task
This role does some post task in primary application server.

## Overview
The installation and configuration of sybase post task involves a number of steps (at a high level):

* modify .devenv.csh file
* restart the instance

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|role|the role of the server|yes|
|sap.sid|sid for installation directory|yes|
|instance_number|instance number of the application|yes|




## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sybase-post-task
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/example-sap/browse/golden_scenarios/azure/scenario106/ansible/inventory)

## Checks
To validate that sybase is installed, you can run the following command(installation folders should be created). Login to the database and check the auditdb and cmsdb :
```bash
cd /sybase/SID
isql -S SID -U sa -P PWD
sp_helpdb
go
```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]


* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1398

