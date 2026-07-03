# db2_hadr_secondary
This role is used to update the hadr properties for secondary db in db2 database.

## Overview
This role will update the hadr properties and restore offline backup taken from in primary database.

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
|minor|added the secondary hadr commands for db2 suse in azure|Apoorva|-|
|minor|added the secondary hadr commands for db2 redhat in aws|Apoorva|-|
|minor|added node 1 and node 2 in HADR commands HADR_LOCAL_HOST|Apoorva|21st Nov 2022|

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]


## Reference
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1601