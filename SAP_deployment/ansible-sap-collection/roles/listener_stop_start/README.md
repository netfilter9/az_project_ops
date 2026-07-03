# listener_start_stop
This role stops the listener and restarts it.

## Role variables
The variables to be used within this role are  defined at group_vars at db level

### group variables (common)
|variable|info|required?
|---|---|---|
|sap.db.installation_user|oracle database installation default user|no|
|sap.db.sid|database sid|yes|
|sap.db.software_version|database software version|yes|

## Checks
To check lisntener status you can run following command in the VM:
```bash
 lsnrctl status
```
## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1540

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)




