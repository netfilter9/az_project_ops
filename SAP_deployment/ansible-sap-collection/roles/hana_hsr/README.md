# hana_hsr
This role performs the hana system replication between 2 cluster nodes.

## Overview
Before this role cluster configuration should be done between these 2 nodes. Also hana software needs to be installed on both the nodes.
Here are the tasks mentioned below:
1. Copy the system PKI files from primary to the secondary node.
2. Taking the hana db backup in primary node.
3. Taking the one or multiple tenant db backup in primary node.
4. Creating the primary site.
5. Configure systemreplication in sceondary node.

The following roles (or cloud/os specific alternatives) should already have been deployed to the two cluster nodes where required:
```yaml
  roles:
    - hostfile_generation #(optional)
    - sbd_managed_node #(optional - depends on sbd approach)
    - crm-cluster-node
    - filesystem
    - swapfile #(optional - depends on swapfile approach)
    - anf_config #(optional - depends on anf approach)
    - mounts #(optional - depends on anf approach)
    - azcopy-install
    - sap-download
    - sap-tune
    - hana_db
    - hana_hsr
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables
|variable|info|required?|
|---|---|---|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|
|sap.db.sid|db sid of the hana system|yes|
|sap.instance_numbers.hana|db instance number of the hana system|yes|
|sap.db.site.primary_name|site name of primary hana node(needed for multiple dbsid in single hana system)|no (By dafaults it will take 'SITE1' )|
|sap.db.site.secondary_name|site name of secondary hana node(needed for multiple dbsid in single hana system)|no (By dafaults it will take 'SITE2' )|
|sap.db.site.primary_hostname|hostname of the primary site (needed for multiple dbsid in single hana system)|no (By dafaults it will take virtual hostname in hostvars )|
|passwords.system|password used for the database system|yes|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/scenario17/ansible/playbooks/02_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/scenario17/ansible/inventory)

## Checks
To validate that hana hsr is working fine, you can run the following command from the first cluster node:
```bash
su - {{ sap.db.sid|lower }}adm -c "hdbnsutil -sr_state"
```
or we can validate with below command also in primary node:
```bash
su - {{ sap.db.sid|lower }}adm
cdpy
python systemReplicationStatus.py
```

Output will vary depending on the specific cluster resources configured for the target platform.

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Taking one or multiple tenant db backup on primary node.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-585

2. Creating site for multiple dbsid on primary and secondary nodes.

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-701

3. Restructuring the task as per the platform -Azure,AWS and GCP

## References
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-125
2. For more referance please check: https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability