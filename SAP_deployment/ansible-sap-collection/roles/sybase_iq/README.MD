# Sybase_iq
This role install's SAP IQ Server Suite and SAP IQ Client Suite in the server.

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (sybaseiq)
|variable|info|required?|
|---|---|---|
|role|the role of the server|yes|
|sybase_iq_user|User name for sybase_iq|no|
|sybase_iq_group|group name for sybase_iq|no|
|install_path|path for sybase_iq installation|no|
|RMI_Port|RMI_port number for sybase_iq install|no|
|TDS_Port|TDS_port number for sybase_iq install|no|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - sybase_iq
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/example-sap/browse/golden_scenarios/aws/scenario146/ansible/inventory)


## Checks
To validate that sybase_iq is installed,
```bash
cd /usr/sap/sybase_iq/install_dir/Logs
Check for installation successful massege in iq_suite.log
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1783