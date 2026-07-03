# cloud_connector
This role installs the cloud connector software on a VM .

## Overview
The installation and configuration of cloud connector software involves a number of steps (at a high level):

* Install jdk
* Update profile 
* Install cloud connector software

## Role variables
There are no inputs required for this role

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - cloud-connector
```

## Checks
To validate that cloud connector is installed, open below link in browser
 https://myseverip:8443/ 


## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-569
