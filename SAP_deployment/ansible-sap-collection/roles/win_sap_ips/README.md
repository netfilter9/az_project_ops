# win_sap_ips

This role installs the IPS component of BODS.

## Overview
The installation and configuration of IPS software involves a number of steps :

* creating ips config file
* rebooting the vm
* Install IPS software

## Example playbook

```yaml
---

- name: windows bods install
  hosts: std
  roles:
    - win_sap_ips
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
