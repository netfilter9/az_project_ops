# sap-ips
This role installs the MAXDB software and dbload on a VM .

## Overview
The installation and configuration of MAXDB software involves a number of steps (at a high level):

* Install MAXDB software and dbload
* Update DB S/W
* Retry DB load (if fails)

## Role variables
The variables to be used within this role are all defined at  group level, host level and playbook level .

### group variables (all)
|variable|info|required?|
|---|---|---|
|root_dir|installation directory|yes|
|sap.db.sid|SID of the MAXDB install|yes|
|product_id|db product id|yes|
|sap.instance_numbers.db_instance|instance number for the MAXDB instance|yes|
|passwords.admin|password for the standard os admin user|yes|
|passwords.master|master password for MAXDB install|yes|
|passwords.sapadm|password for the sapadm user|yes|
|passwords.system|password for system user|yes|
|passwords.sidadm|password for sidadm user|yes|
|passwords.systemdb|password for systemdb user|yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - max_db
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/examples-sap/browse/golden_scenarios/gcp/scenario155/ansible/inventory)

## Checks
To validate that sybase is installed, you can run the following command(installation folders should be created). Login to the database and check the auditdb and cmsdb :
```bash
 su - <sqdsid> OR su - <sidadm>
 dbmcli
 dbmcli -U C  (to login into db)
 dbmcli -u control,PWD -d SID db_state  (db status check)

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* Install MAXDB software and dbload
* Update DB S/W
* Retry DB load (if fails)

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1732

