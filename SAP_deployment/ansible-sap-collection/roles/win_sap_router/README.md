# win-sap-router

This role install the additional Non-SAP product SAP router.

# Overview

Pre-requisites for windows Cloud Connector:

1. windows VM should be domain joined.
2. This product can be installed on existing SAP installed VM or in standalone VM.


An example playbook for win cloud connector may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: std
  gather_facts: yes
  roles:
    - win-sap-router
```

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New Role to be created as win-sap-router

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-910


