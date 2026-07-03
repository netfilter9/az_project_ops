# Create wallet
This role creates and sets up password wallet

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.db.installation_user|Name of oracle installation user needs to be passed|No|
|passwords.master|master password of wallet|Yes|
|sap.db.software_version|software version for observer|Yes|

### group variables (observer)
|variable|info|required?|
|---|---|---|
|observer_sid|SID observer instance|Yes|
|primary_instance_ch|Charecter needs to be passeed|Yes|
|secondary_instance_ch|Charecter needs to be passeed|Yes|

## checks
Check whether the wallet is created in /oracle/download

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1536

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)