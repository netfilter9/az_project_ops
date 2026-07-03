# Standby-db-config
This role runs the dg config commands on the secondary database after synching.

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|Name of oracle installation user needs to be passed|No|
|sap.db.db_user|Name of db user|No|
|passwords.master|master password for client install|Yes|
|sap.db.software_version|software version for observer|Yes|

### group variables (db)
|variable|info|required?|
|---|---|---|
|sap.db.sid|SID database instance|Yes|
|db_secondary_hostname|secondary or virtual hostname for secondary database|NO|
|dbnode2|secondary database|yes|
|port|port number for database|No|

## checks
Check the status of flashback--> it should be on.

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1543

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)