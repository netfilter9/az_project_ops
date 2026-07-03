# sap-java-postreqs
This role does post installation step for java stack.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|sap.sid|SID of the sap install|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenarios/azure/scenario70/ansible/playbooks/10_java_pas.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/azure/scenario70/ansible/inventory)

## Checks
To validate that the file is modified:
```bash
cat icm_filter_rules.txt
```

## License
Accenture use only

## References 
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-607