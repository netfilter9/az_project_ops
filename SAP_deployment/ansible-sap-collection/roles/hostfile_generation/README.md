# hostfile_generation
This role modifies the /etc/hosts file in server.

## Overview
hosts file is very much important for connection between the application and databse VMs.

## Role variables
There are no role variables used.

### group variables (all)
|variable|info|required?|
|---|---|---|
|virtual_hostname|virtual_hostname through which ascs, db, pas is going to be installed|no|
|virtual_ip|virtual_ip through which ascs, db, pas is going to be installed|no|
|sap.logical_hosts|sap.logical_hosts through which ascs, db, pas is going to be installed|yes (if there is no virtual hostanem we have to pass physical hostname)|
|update_host_file|if the entry of the physical host is not needed, we can pass it false|no|
|new_marker|name of the new scenario running again on the server|no|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - hostfile-generation
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/golden_scenarios/azure/scenario34/ansible/inventory)

## Checks
To validate the hosts file, you can run the following command:

```bash
cat /etc/hosts
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* Changing the ordering of hostname parameter in host.j2 file to get the hostname -f output with fqdn value.
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-126