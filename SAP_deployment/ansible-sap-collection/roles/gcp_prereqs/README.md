# gcp_prereqs
This role installs Google Cloud SDK components which include gcloud and gsutil command-line tools also installs the required packages for RHEL8 based on OS.

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
ls /usr/bin/google-cloud-sdk/bin/gcloud
ls /usr/lib/google-cloud-sdk/bin/gsutil
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Installing the default Google Cloud SDK components, which include gcloud and gsutil command-line tools.
2. Added installation of pre requisite packages required for Rhel8  also.

Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1105


