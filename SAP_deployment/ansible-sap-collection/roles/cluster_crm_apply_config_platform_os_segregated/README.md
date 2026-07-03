# cluster_crm_apply_config_platform_os_segregated
This role applies a specific cluster configuration profile (crm config) to an existing base cluster and has separate scripts and templates based on platform and os to be run as pilot before replacing the existing roles.

The target cluster profile is selected by setting the `cluster_type` variable.  Valid profiles are:
* `ascs_nosap` - used for ascs/ers clusters to setup shared file system before installing application
* `ascs_sap` - used to configure the final ascs/ers cluster post SAP softwre installation
* `hana` - used to configure the final hana cluster post software install and HSR configuration
* `nfs` - used to set up filesystem failover on a server based NFS cluster
* `db2` - used to set up db2 cluster primitives post software install and HADR configuration

## Overview
Pre-requisites will change based on the specific cluster type being deployed.
1. The entire role will be executed in primary node.
2. cluster_config file will be generated in home directory of the node.
3. In next task it will keep the primary node in maintanance mode.
4. cluster configuration done in that role.
5. Primitives like stonith, vip, nc, fs etc. are configured.
6. Again the node will be brought back to out of maintance mode. 

An example playbook for an nfs cluster may look like this:

```yaml
# gather facts from all hosts for hostfile generation
- hosts: all!vips

# setup new nfs cluster
- hosts: nfs
  roles:
    - hostfile_generation
    - cluster_crm_node
    - nfs
    - cluster_crm_apply_config
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (common)
|variable|info|required?|
|---|---|---|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|
|stonith_type|type of stonith device being used (`gcp`\|`sbd`) used to configure cluster resources|yes|
|platform|target platform (`azure`\|`gcp`\|`aws`) used to configure cluster resources|yes|
|lb_type|the type of load balancer being used (`azure`\|`gcp_alias`)|yes|
|cluster_type|the type of cluster being configured (`ascs_nosap`\|`ascs_sap`\|`hana`\|`nfs`)|yes|
|vpc_type|the VPC model|no (it is defined only 'shared' model is being used)|
|vpc_account_number|VPC account number of parent aws account|no (it should be defined shared VPC model is being used)|
|vpc_account_cluster_role|iam role that should be atteched with the parent VPC|no (it should be defined shared VPC model is being used)|
|hana_healthcheck_port|healthcheck port used for hana LB (`gcp`)|yes|
|ascs_healthcheck_port|healthcheck port used for ascs LB (`gcp`)|yes|
|ers_healthcheck_port|healthcheck port used for ers LB (`gcp`)|yes|

### group variables (ascs/ers cluster)

|variable|info|required?|
|---|---|---|
|sap.logical_hosts.ascs.ip|virtual ip address for ascs instance|yes|
|sap.logical_hosts.ascs.cidr|the cidr netmask of ascs machines|yes|
|sap.logical_hosts.ers.ip|virtual ip address for ers instance|yes|
|sap.logical_hosts.ers.cidr|the cidr netmask of ers machines|yes|
|sap.instance_numbers.ascs|instance number for ascs component|yes|
|sap.instance_numbers.ers|instance number for ers component|yes|
|sap.sid|SAP SID identifier|yes|
|sap.ascs_type|ASCS type based on ABAP vs JAVA (`ASCS`\|`SCS`)|yes|
|sap.nfs.volume_ref |ASCS/ERS volume refernce in anf|no (it is needed only when anf is being used)|
|sap.nfs.ascs_device |ASCS/ERS volume folder path in anf|no (it is needed only when anf is being used)|
|sap.nfs.fstype |ASCS/ERS fstype in anf|no (it is needed only when anf is being used)|
|sap.nfs.options |ASCS/ERS options in anf|no (it is needed only when anf is being used)|
|enq_architecture|enqueue server archiecture for cluster, value can be ENSA1 (NW750) or ENSA2 (S4HANA,NW752)|no (defaults added 'ENSA2')|

### group variables (hana cluster)

|variable|info|required?|
|---|---|---|
|sap.logical_hosts.db.ip|virtual ip address for hana cluster|yes|
|sap.instance_numbers.hana|SAP instance number for HANA component|yes|
|sap.db.sid|the SAP SID assigned to the database|yes|
|sap.logical_hosts.db.cidr|the cidr netmask of DB machines|yes|
|primitives.db.automatic_register|value of automatic register|no (dafault value is 'false')|

### group variables (nfs cluster)

|variable|info|required?|
|---|---|---|
|nfs_virtual_hostname|virtual host hane for nfs cluster|yes|
|shares|an array of shares to be created in the NFS server|yes|
|shares[share].ref|a unique reference identifier for the share|yes|
|shares[share].drbd_num|the drbd device number associated with the share|yes|
|shares[share].mount|the mount point associated with the share|yes|
|shares[share].fstype|the fstype used for the share|yes|
|shares[share].fsid|the unique fsid assigned to the share|yes| 
|shares[share].lb_port|the loadbalancer port associated with the share on the cluster|yes|
|shares[share].ip|the ip address of the loadbalancer assocaited with the share on the cluster|yes|
|nfs_type|the type of nfs server being used (`server`)|yes|

### group variables (db2 cluster)

|variable|info|required?|
|---|---|---|
|sap.lb_ip|ip for db2 LB|yes|
|sap.db.sid|db sid for db2 cluster primitives configuration|yes|
|db_overlay_ip|overlay ip for aws db2 cluster|yes|
|route_table_id|route table id for aws db2 cluster|yes|

## Checks
To validate that the cluster is up and running, you can run the following command from the first cluster node:
```bash
sudo crm_mon -1
```

Output will vary depending on the specific cluster resources configured for the target platform.

## Code Update

|Type of release(create a new line for each release) - interface breaking(major), feature or minor |Reason for code update|Date|Author|
|---|---|---|
|feature|Added this new role to run as a pilot for testing and deployment|29th Oct 2024|Mrunal|

## License
Accenture use only

## Design
[Cloud Builder Developer Team design]

## Reference

1. For more referance please check:
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse
2. https://cloud.google.com/solutions/sap/docs/netweaver-ha-config-sles#ensa1_1
3. https://documentation.suse.com/sbp/all/html/SLES4SAP-hana-sr-guide-PerfOpt-15/index.html
4. https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/dbms-guide-ha-ibm
5. https://aws.amazon.com/blogs/architecture/field-notes-set-up-a-highly-available-database-on-aws-with-ibm-db2-pacemaker/     
