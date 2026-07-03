# win-sybase-post-hadr

This role perform the post HADR configurations for sybase windows HA.
Steps:
1. copy the post HADR response files.
3. execute sybase isql command.
4. run rsecssfx command to update passwords.


An example playbook for win domain join may look like this:

```yaml

- name: perform the HADR configurations for sybase windows HA
  hosts: mssql
  gather_facts: yes
  roles:
    - win-sybase-post-hadr
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|sap.install_drive|Install drive for SAP|yes|
|domain.fqdn|domain name|yes|
|sybase_db_password|sybase db password|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/users/anisha.baskey/repos/examples-sap/browse/golden_scenarios/azure/scenario136/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/users/anisha.baskey/repos/examples-sap/browse/golden_scenarios/azure/scenario136/ansible/inventory)

## Checks
To validate that the SQL availabilty group configurations are completed:

```powershell
rsecssfx list
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New role for post sybase windows HADR configuration to be added.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1459


