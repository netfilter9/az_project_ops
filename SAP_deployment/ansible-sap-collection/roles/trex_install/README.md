# trex_install
This role performs Trex installation.

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|sap.sid| value of sid needs to be passed |yes|
|passwords.system|password for system user needs to be passed.|yes|
|root_dir| value of root directory needs to be passed.|yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - trex_install
```

## Checks
We can validate the configuration:
```bash
    Execute TREXSettings.sh or TREXSettings.csh
    Execute TREXAdmin.sh but this needs Display to be set
    Execute ./TREX stop
    Execute ./TREX start
    Execute ./TREX version
```

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1825

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)