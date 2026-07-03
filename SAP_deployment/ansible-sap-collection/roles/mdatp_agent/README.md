# mdatp-agent

This role perform the Microsoft Defender for Endpoint for Linux with Ansible.
Steps:
2. onboards the mdatp binary.
3. Activate the mdatp agent.

# Overview

Pre-requisites for windows mdatp-agent role:

1. key to be provided in ansible vault .

An example playbook for win domain join may look like this:

```yaml

- hosts: mdatp
  become: yes

  roles:
    - mdatp-agent
```

## Role variables
The variables to be used within this role are all defined at ansible vault.

### group variables (windows)
|variable|info|required?|
|---|---|---|
|mdatp_id|id for mdatp for debian VM|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario04/ansible/playbooks)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario04/ansible/inventory)

## Checks
To validate that the mdatp is installed:

```shell
ansible -m shell -a 'mdatp connectivity test' all
ansible -m shell -a 'mdatp health' all
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New role to be added for qualys installation on various platforms.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-834


