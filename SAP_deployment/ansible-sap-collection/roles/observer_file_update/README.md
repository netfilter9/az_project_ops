# Observer-file-update
This role updates the files.

## Overview
The Observer-file-update involves a number of steps (at a high level):

* setting username
* updating the sqlnet file 
* updating the tnsnames file 

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (all)
|variable|info|required?|
|---|---|---|
|observer_sid|SID of the observer|Yes|
|sap.db.sid|SID of the DB|Yes|

### group variables (observer)
|variable|info|required?|
|---|---|---|
|primary_instance_ch|Charecter needs to be passeed|Yes|
|secondary_instance_ch|Charecter needs to be passeed|Yes|
|dbnode1|Hostname of the primary DataBase|Yes|
|dbnode2|Hostname of the secondary DataBase|Yes|
|port|Port number for observer|No(takes default value)|
|db_primary_hostname|secondary or virtual hostname for Primary database|No|
|db_secondary_hostname|secondary or virtual hostname for Secondary database|No|
|observer_sid| SID of observer|yes|

## Checks
Check whether sqlnet.ora and tnsnames.ora files are updated in /oracle/OBS/19/network/admin/.

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1537

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

