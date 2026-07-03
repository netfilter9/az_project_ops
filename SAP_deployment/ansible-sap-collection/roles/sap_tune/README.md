# sap-tune
This role initialises the saptune and sapconf configuration .

## Overview
The installation and configuration of sap-tune involves a number of steps (at a high level):

* install required pacakages for specific OS.
* install sap-tune profile
* set sap-tune profiles
* Start/stop service
* Modify few OS configurations

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|tune|the value of tune needs to be passed. Ex.BOBJ,MAXDB,NETWEAVER,NETWEAVER+HANA,S4HANA-APP+DB,S4HANA-APPSERVER,S4HANA-DBSERVER,SAP-ASE|yes|


## Example playbook

```yaml
---
- hosts: myserver
  roles:
    - sap-tune
```

## Example inventory

See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc36-nw750abap-hana-suse-2tier-nonha-anf/ansible/inventory)

## Checks
We can validate the configuration:

saptune for SLES:
```bash
saptune solution list | grep '*'
```
saptune for RHEL:
```bash
tuned-adm list
```


## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)



