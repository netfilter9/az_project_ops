# gcp_cluster_prereqs
This role installs GCP specific cluster resources.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
There are no inputs required for this role

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/gcp/sc08-s41809-hana-suse-nonha/ansible/playbooks/01_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/gcp/sc08-s41809-hana-suse-nonha/ansible/inventory)

## Checks
To validate that install has been completed:
```bash
ls /usr/lib64/stonith/plugins/external/gcpstonith
ls /usr/lib/ocf/resource.d/gcp/alias
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Downloading GCP specific cluster resources(stonith and alias).
2. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-563

