# password_reset
This role resets the password for the specified user

## Overview
There are no specific pre-requisites for this role, user should be present before resetting the password. 

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|password_reset|an array of user name and password to be set|yes|
|password_reset[loopindex].name|name of the user|yes|
|password_reset[loopindex].password|password of the user|yes| 

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - password-reset
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/scenario10/ansible/inventory)

## Checks
```bash
#login with the username 
su - username
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References
[Cloud Builder Developer Team design]