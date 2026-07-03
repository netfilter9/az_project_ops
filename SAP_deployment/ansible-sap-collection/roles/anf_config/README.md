# anf_config
This role initialises configurations for azure net app files.

## Overview
The anf configuration involves a number of steps (at a high level):

* NFS domain settings
* nfs4_disable_idmapping set to Y
* Change in DHCP and cloud config settings for the network interface for storage 
* Addition of the network route


## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|hana_scale_out.anf | value of hana_scale_out.anf needs to be passed.|yes|
|hana_scale_out.storage_subnet|the ip value of storage subnet needs to be passed.|yes|
|hana_scale_out.storage_routerip | value of router ip of the storage subnet needs to be passed.|yes|
|hana_scale_out.anf_subnet|the ip value of anf subnet needs to be passed.|yes|


## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - anf-config
```

## Example inventory
N/A

## Checks
We can validate the configuration:
```bash
cat /etc/idmapd.conf
cat /etc/sysctl.d/netapp-hana.conf
cat /etc/sysctl.d/ms-az.conf
cat /etc/modprobe.d/sunrpc.conf
#for SUSE
cat /etc/sysconfig/network/dhcp
cat /etc/sysconfig/network/ifroute-eth1
#for RHEL
cat /etc/sysconfig/network-scripts/route-Wired_connection_1 

```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)