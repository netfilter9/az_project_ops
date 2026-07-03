# cluster_crm_node
This role applies a specific cluster configuration profile (crm config) to an existing base cluster.

The target cluster profile is selected by setting the `cluster_type` variable.  Valid profiles are:
* `ascs_nosap` - used for ascs/ers clusters to setup shared file system before installing application
* `ascs_sap` - used to configure the final ascs/ers cluster post SAP softwre installation
* `hana` - used to configure the final hana cluster post software install and HSR configuration
* `nfs` - used to set up filesystem failover on a server based NFS cluster

## Overview
Pre-requisites will change based on the specific cluster type being deployed.
1. The entire role will be executed in primary node.
2. cluster_config file will be generated in home directory of the node.
3. In next task it will keep the primary node in maintanance mode.
4. cluster configuration done in that role.
5. Primitives like stonith, vip, nc, fs etc. are configured.
5. Again the node will be brought back to out of maintance mode. 

An example playbook for an nfs cluster may look like this:

```yaml
# gather facts from all hosts for hostfile generation
- hosts: all!vips

# register new sbd cluster reference
- hosts: sbd
  vars:
    node1: "{{ groups['nfs'][0] }}"
    node2: "{{ groups['nfs'][1] }}"
    cluster_ref: "{{ hostvars[groups['nfs'][0]].cluster_ref }}"
  roles:
    - sbd-register-cluster

# setup new nfs cluster
- hosts: nfs
  roles:
    - hostfile-generation
    - sbd-managed-node
    - cluster-crm-node
    - nfs
    - cluster-crm-apply-config
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
|app_id|client id of SPN in azure platform|yes|
|app_pass|client secret of SPN in azure platform|yes|
|tenant_id|tenent id of resource group and SPN in azure platform|yes|
|subscription_id|subscription id of resource group and SPN in azure platform|yes|
|resource_group|resource group name where the servers are placed in azure platform|yes|


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


## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/playbooks/05_ascs_ers.yml)
[Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/scenario17/ansible/playbooks/02_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/inventory)
[Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/golden_scenarios/scenario17/ansible/inventory)

## Checks
To validate that the cluster is up and running, you can run the following command from the first 
cluster node:
```bash
sudo crm_mon
```

Output will vary depending on the specific cluster resources configured for the target platform.

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Modifying the hana_config.j2 template for primitives.
2. Modifying the below primitives.
```bash
primitive rsc_SAPHana_{{ instance }} ocf:suse:SAPHana \
	operations $id="rsc_sap_{{ instance }}-operations" \
	op start interval="0" timeout="3600" \
	op stop interval="0" timeout="3600" \
	op promote interval="0" timeout="3600" \
	op monitor interval="10" role="Master" timeout="700" \
	op monitor interval="11" role="Slave" timeout="700" \
	params SID="{{ sap.db.sid }}" \
  InstanceNumber="{{ sap.instance_numbers.hana }}" \
  PREFER_SITE_TAKEOVER="true" \
	DUPLICATE_PRIMARY_TIMEOUT="7200" \
  AUTOMATED_REGISTER="false"

ms msl_SAPHana_{{ instance }} \
  rsc_SAPHana_{{ instance }} \
	meta is-managed="true" notify="true" clone-max="2" clone-node-max="1" \ 
  targetrole="Started" interleave="true"

{#
    Add vip resource
#}
primitive vip_{{ instance }} IPaddr2 \
  params ip={{ db_lb_ip }} cidr_netmask={{ db_cidr }} nic=eth0 \
  op monitor interval=10 timeout=20

{% elif lb_type == "azure" %}
{# Traditional Azure loadbalancer #}
primitive nc_{{ instance }} azure-lb \
  port=625{{ sap.instance_numbers.hana }}
{% endif %}
```
3. Modifying the role for cluster configuration in AWS platform.
4. Modifying the role for RHEL OS.

## Reference
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-119
2. For more referance please check:
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse