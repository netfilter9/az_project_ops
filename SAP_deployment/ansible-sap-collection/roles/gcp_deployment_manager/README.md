# gcp_prereqs
This role deploys hana-scaleout using GCP deployment manager.

## Requirements
There are no specific pre-requisites for this role.

## Role variables
|variable|info|required?|
|---|---|---|
|instanceName|name of master worker node|yes|
|instanceType|size of vm|yes|
|zone|zone of vm|yes|
|subnetwork|subnet of vm|yes|
|linuxImage|os type|yes|
|linuxImageProject|os family|yes|
|sap_hana_deployment_bucket|bucket name|yes|
|sap_hana_sid|deployment sid|yes|
|sap_hana_instance_number|instance number|yes|
|sap_hana_sidadm_password|sidadm password|yes|
|sap_hana_system_password|system user pssword|yes|
|sap_hana_worker_nodes|no of worker node|yes|
|sap_hana_standby_nodes|no of standby node|yes|
|sap_hana_shared_nfs|nfs server path for hana shared|yes|
|sap_hana_backup_nfs|nfs server path for hana backup|yes|

## Example playbook
https://innersource.accenture.com/projects/IASC/repos/examples-sap/browse/golden_scenarios/gcp/scenario157?at=refs%2Fheads%2Fstaging

## Example inventory
https://innersource.accenture.com/projects/IASC/repos/examples-sap/browse/golden_scenarios/gcp/scenario157?at=refs%2Fheads%2Fstaging

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

Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1735