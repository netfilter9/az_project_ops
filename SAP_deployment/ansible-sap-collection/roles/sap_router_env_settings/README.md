# sap-router-env-settings
This role configures the environment variables for sap router.

## Overview
The installation and configuration of sap-router-env-settings involves a number of steps (at a high level):

* configure /etc/environment
* set SECUDIR=/usr/sap/saprouter
* set SNC_LIB=/usr/sap/saprouter/lib/libsapcrypto.so
* set LD_LIBRARY_PATH=/usr/sap/saprouter/lib
* LIBPATH=/usr/sap/saprouter/lib

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

## Example playbook

```yaml
---
- hosts: myserver
  roles:
    - sap-router-env-settings
```

## Example inventory

See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario36/ansible/inventory?at=refs%2Fheads%2Ffeature%2FACNCSSPR-1026-scenario-36-vishal)

## Checks
We can validate the configuration:

sap-router-env-settings for SLES:
```bash
cat /etc/environment
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Ticket Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-138 