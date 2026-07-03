# win_sap_ds

This role installs the ds component of BODS.

## Overview
The installation and configuration of DS software involves a number of steps :

* creating ds config file
* Install DS software
* Rebooting the VM

## Example playbook

```yaml
---

- name: windows bods install
  hosts: std
  roles:
    - win_sap_ds
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples//browse/golden_scenarios/azure/scenario124/ansible/inventory)

## Checks
To validate that DS is installed, open browser and hit 
  
http://<bodsserverip>:8080/BOE/CMC

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1302
