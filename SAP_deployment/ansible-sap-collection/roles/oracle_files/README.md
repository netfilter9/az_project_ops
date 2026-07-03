# Oracle-files
This role creates passwd file. Also it creates data and log directories

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|Name of oracle installation user needs to be passed|No|
|passwords.master|master password for orapwd file|Yes|
|sap.db.software_version|software version for observer|Yes|

### group variables (observer)
|variable|info|required?|
|---|---|---|
|sap.db.sid|SID of db instance|Yes|

## checks
Check whether the data and log directories are created in /oracle/NW1/

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1541

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)