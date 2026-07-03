# win_sap_is

This role installs the IS component of BODS.

## Overview
The installation and configuration of IS software involves a number of steps :

* creating IS config file
* Install IS software

## Example playbook

```yaml
---

- name: windows bods install
  hosts: std
  roles:
    - win_sap_is
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/examples-sap//browse/golden_scenarios/azure/scenario124/ansible/inventory)

## Checks
To validate that IPS is installed, open browser and hit 
  
http://<bodsserverip>:8080/BOE/CMC

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1302
