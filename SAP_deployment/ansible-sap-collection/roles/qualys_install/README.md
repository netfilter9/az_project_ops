# qualys_install

This role perform the Qualys agent installation.
Steps:
2. Install the qualys binary.
3. Activate the qualys agent.

# Overview

Pre-requisites for windows Sofs role:

1. Activation key to be provided in ansible vault.
2. Customer id to be provided in ansible vault.

An example playbook for win domain join may look like this:

```yaml

- hosts: ascs
  become: yes

  roles:
    - qualys-install
```

## Role variables
The variables to be used within this role are all defined at ansible vault.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|activation_id|Activation keys for qualys agent|yes|
|customer_id|customer id for qualys agent|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario04/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario04/ansible/inventory)

## Checks
To validate that the qualys is installed:

```shell
ps -ef | grep qualys
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New role to be added for qualys installation on various platforms.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-834


