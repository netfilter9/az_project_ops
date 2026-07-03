# win-cloud-connector

This role install the additional Non-SAP product Cloud Connector.

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
    - win-cloud-connector
```

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc16-mssql-2tier-ad/ansible/inventory)

## Checks
To validate that the VM is domain joined, you can run the following command in target win VM:

```powershell
$software = "Cloud Connector";
$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -eq $software }) -ne $null

```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New Role to be created as win-cloud-connector

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-667


