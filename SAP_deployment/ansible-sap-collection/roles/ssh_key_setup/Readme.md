# ssh-key-setup
This role set up the ssh keys and adds public key to the target node. 

## Overview
There are no specific pre-requisites for this role. public ssh key will be added to the target node. This role is creating the ssh key and add it to the target nodes. This is required for RHEL.

## Role variables
The variables to be used within this role are all defined at group_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|ssh_key_setup_nodes|an array of nodes to be set|yes|

## Example playbook
```yaml
---
- hosts: servergroup
  roles:
    - ssh-key-setup
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenario/scenario10/ansible/inventory)

## Checks
```bash
#login to the target node and verify the public is present
cat authorized_keys
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References
[Cloud Builder Developer Team design]

* Ticket reference https://alm.accenture.com/jira/browse/ACNCSSPR-43 