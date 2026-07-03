# oracle_tns_name
This role will update the tns file. 

## Role variables
The variables required are defined at group_vars at db level

### group variables (common)
variable|info|required?|
|---|---|---|
|sap.db.installation_user|oracle database installation default user|no|
|sap.db.db_user|default database user|no|
|sap.db.software_version|database software version|yes|
|dbnode1|primary database|yes|
|dbnode2|secondary database|yes|
|sap.db.sid|database sid|yes|
|root_dir|specified root directory|yes
|primary_instance_ch|character representing primary db instance|yes|
|secondary_instance_ch|character representing secondary db instance|yes|
|instance_ch|character for current database instance|yes|
|port|port for oracle db|no|
|virtual_hostname|virtual hostname of database|yes|
|db_primary_hostname|secondary or virtual hostname for Primary database|No|
|db_secondary_hostname|secondary or virtual hostname for Secondary database|No|

## Checks
To check updated lisntener file in the VM:
```bash
  cat /network/admin/tns.ora 
```
## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1539

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)
