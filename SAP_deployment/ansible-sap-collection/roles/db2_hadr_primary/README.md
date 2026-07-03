# db2_hadr_primary
This role is used to update the hadr properties for primary db in db2 database.

## Overview
This role will update the hadr properties and take offline backup of the database.

## Role variables
The variables to be used within this role are at playbook level.

### playbook variables (common)
|variable|info|required?|
|---|---|---|
|root_dir|root directory to be set|no default(usr/sap)|

### group variables (common)
|variable|info|required?|
|---|---|---|
|node1|db instance primary|yes|
|node2|db instance secondary|yes|
|sap.db.sid|sid for db|yes|
|sap.firewall.primary_port|firewall port in primary db|no default(51012)|
|sap.firewall.secondary_port|firewall port in secondary db|no default(51013)|

## Checks
check the 'output of backup verification' task: It should be successful

## Code Update 
|Type of change - interface breaking or minor |Reason for code update|Author|Date|
|---|---|---|---|
|minor|added the hadr_prereqs for db2 aws|Apoorva|-|
|minor|added the primary hadr commands for db2 aws|Apoorva|-|
|minor|added the condition to run hadr_prereqs_azure only for Redhat OS|Apoorva|21st Nov 2022|

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

## Reference
[Cloud Builder Developer Team design]

