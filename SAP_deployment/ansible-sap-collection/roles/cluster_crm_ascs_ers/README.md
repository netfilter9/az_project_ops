# cluster_crm_ascs_ers
This role performs the SAP software installation and cluster configuration for a new system install 

## Overview
The SAP install software should already have been downloaded to the nfs server. Here are tasks done in the role.
1. It will configure the nonsap primitives on cluster.
2. Next it will install ASCS/SCS on primary node.
3. It will install ERS on secondary node.
4. Configurion of ASCS/SCS and ERS instance profile on both the nodes.
5. Adding sidadm in haclient group
6. Add ASCS/SCS service in secondary node and ERS service in primary node.
7. Atlast it will configure the sap primitives on cluster.

If server based SBD is being used, the cluster reference should already have been registered.

The following roles (or cloud/os specific alternatives) should already have been deployed to the two cluster nodes where required:
```yaml
  roles:
    - hostfile_generation #(optional)
    - sbd_managed_node #(optional - depends on sbd approach)
    - crm_cluster_node #(optional - depends on cluster software)
    - filesystem #(required - creates filesystem for install)
    - swapfile #(required - sets up swapfile)
    - nfs_mounts #(required - we should always perform install from nfs mount)
```

## Role variables
Variables to be used with this role must be added with different scopes. Some of the variables can be applied to both hosts, and some of them must apply individually to each host. This is due the nature of SAP System, where hosts will have different primary roles (ASCS and ERS) in the SAP architecture.

### Common variables
|variable|info|required?|
|---|---|---|
|ascs_virtual_hostname|virtual hostname for SAP ASCS instance|yes (can just be the ASCS hostname)|
|ers_virtual_hostname|virtual hostname for SAP ERS instance|yes (can just be the ERS hostname)|
|node1|reference for the primary ASCS node|yes|
|node2|reference for secondary ASCS node (primary ERS node)|yes|
|product.ascs_type|product id used during ASCS install|yes|
|product.ers_type|product id used during ERS install|yes|
|sap.instance_numbers.ascs|SAP instance number for ASCS component|yes|
|sap.instance_numbers.ers|SAP instance number for ERS component|yes|
|sap.product|used to lookup product ids (soon to be deprecated)|yes|
|sap.sid|three letter SID used for SAP install|yes|
|ascs_overlay_ip|overlay ip for ascs instance in AWS|yes(in AWS platform)|
|ers_overlay_ip|overlay ip for ers instance in AWS|yes(in AWS platform)|

### Host level variables
|variable|info|required?|
|---|---|---|
|role|servers SAP role (`ascs`\|`ers`)|yes|
|virtual_hostname|virtual hostname for the host|yes|
|virtual_ip|virtual ip address for the host|yes|

### Imported role variables
This role relies on the `sap_install` and `crm_config` roles so please check that role for additional variable definition requirements

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenario/scenario17/ansible/playbooks/03_ascs_ers.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/golden_scenario/scenario17/ansible/inventory)

## Checks
To validate that the cluster is up and running, you can run the following command from the first cluster node:
for SLES:
```bash
sudo crm_mon
```
for RHEL:
```bash
sudo pcs status
```

Output will vary depending on the specific cluster resources configured for the target platform.

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. Modifying the role to add sidadm user to haclient group.
2. Modifying the role to copy the ascs profile to ers machine.
3. Modifying the role to copy the ers profile to ascs machine. 
4. Modifying the role for AWS platform.
5. Modifying the role for RHEL OS.

## Reference
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-112
2. For more referance please check:
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability
   * https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse