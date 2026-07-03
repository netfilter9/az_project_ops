# oracle_client_download
This role installs client in observer server.

## Overview
The oracle client download involves a number of steps (at a high level):

* setting username and primary group
* client download 
* setting permission 
* Unzip a file 

## Role variables
The variables to be used within this role are all defined at group_vars level

Pre-requisites for oracle client download:
* Downloads details needs to be in observer.yml

### group variables(all)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|Name of installation user needs to be passed|No|
|sap.db.primary_installation_group|Name of oracle installation primary group needs to be passed|No|
|root_dir|Root directory for client download|Yes|
|product.bucket_name|aws bucket name|Yes|

## checks
Check binaries are downloaded in /oracle/download/sapinst/CLIENT. After unzip check whether runinstaller is created in /oracle/download/sapinst/CLIENT/client.

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1546

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)