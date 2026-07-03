# oracle_listener
This role will update the Listner file. 

## Role variables
The variables required are defined at group_vars at db level

### group variables (common)
|variable|info|required?|
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
|port|port for oracle db|no|
|passwords.master|password for rman login|yes|
|virtual_hostname|virtual hostname of database|yes|

## Checks
To check updated lisntener file in the VM:
```bash
  cat /network/admin/listener.ora 
```
## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1538

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)
