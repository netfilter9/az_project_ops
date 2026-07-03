# observer
This role installs client in observer server.

## Overview
The observer involves a number of steps (at a high level):

* setting username 
* installing package
* client install
* settingup password wallet

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|Name of oracle installation user needs to be passed|No|
|sap.db.primary_installation_group|Name of oracle installation primary group needs to be passed|No|
|sap.db.software_version|software version for observer|Yes|

### group variables (observer)
|variable|info|required?|
|---|---|---|
|observer_sid|SID of the observer|Yes|

## checks
Check whether the logfile is created in tmp file  

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1545

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)
