# Sybase_iq
This role install's wily agent in the server.

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (sybaseiq)
|variable|info|required?|
|---|---|---|
|sap.sid|sid for wily agent install|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - wily_introscope
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/example-sap/browse/golden_scenarios/gcp/scenario164/ansible/inventory)


## Checks
To validate that sybase_iq is installed,
```bash
cd /usr/sap/sybase_iq/install_dir/Logs
Check for installation successful massege in  /usr/sap/ccms/apmintroscope/install/Introscope_<version>_InstallLog.log
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1795