# sap-backint
This role installs the sap-backint software on a VM .

## Overview
The installation and configuration of sap-backint software involves a number of steps (at a high level):

* Install python2
* copy backint package 
* install aws-backint-agent
* configure global.ini

## Role variables
|variable|info|required?|
|---|---|---|
|dbsid| DB sid |no|

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.sid|DB sid|yes|
|backint.sse_kms_arn| aws sse kms arn key |yes|
|backint.bucket_name| aws bucket name |yes|
|backint.bucket_folder| aws bucket folder |yes|
|backint.bucket_owner_account_id| aws bucket owner account id |yes|
|backint.bucket_region| aws bucket region |yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sap-backint
```

## Checks
To validate that cloud connector is installed, check the installation version using below command
 /usr/sap/{{ DB_SID }}/SYS/global/hdb/opt/hdbbackint -v 


## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1179
