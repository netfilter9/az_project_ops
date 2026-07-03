# sap-install
This role installs sap in server like ascs, ers, db_instance, pas, aas etc.

## Overview
This role is one of several required to deliver a working end to end SAP system and is expected to be executed as part of a runbook like the one below.

In addition, prior to execution it is expected that SAP software has been downloaded to a local NFS share

Example playbook:
```yaml
---
# This forces a gather facts across all hosts
- hosts: all!vip

# install sap on pas machine
- hosts: pas
  vars:
    root_dir: /usr/sap
    role: pas
    virtual_hostname: "{{ pas_virtual_hostname }}"
    virtual_ip: "{{ pas_virtual_ip }}"
    netmask: "{{ pas_virtual_netmask }}"
  roles:
    - hostfile_generation
    - group-setup
    - user-setup
    - filesystem
    - swapfile
    - anf-config
    - mounts
    - azcopy-install
    - sap-download
    - sap-install 
```

## Role variables
The variables to be used within this role are all defined at group level, host level and playbook level .

### group variables (all)
|variable|info|required?|
|---|---|---|
|sap.sid|SID of the sap install|yes|
|sap.db.sid|SID of the HANA install|yes|
|sap.instance_numbers.ascs|instance number for the ascs instance|yes|
|sap.instance_numbers.ers|instance number for the ers instance|yes|
|sap.instance_numbers.hana|instance number for the HANA instance|yes|
|sap.instance_numbers.pas|instance number for the pas instance|yes|
|sap.instance_numbers.aas|instance number for the aas instance|yes|
|ascs_virtual_hostname|virtual hostname for ascs|no (it depends on architecture)|
|ers_virtual_hostname|virtual hostname for ers|no (it depends on architecture)|
|pas_virtual_hostname|virtual hostname for pas|no (it depends on architecture)|
|db_lb_hostname|virtual hostname for hana|no (only in HA architecture)|
|passwords.admin|password for the standard os admin user|yes|
|passwords.master|master password for HANA install|yes|
|passwords.sapadm|password for the sapadm user|yes|
|passwords.system|password for system user|yes|
|passwords.sidadm|password for sidadm user|yes|
|passwords.systemdb|password for systemdb user|yes|
|users.sidadm.uid|uid for the \<sapsid\>adm|no (although null is allowed)|
|users.dbsidadm.uid|uid for the \<dbsid\>adm user|yes (although null is allowed)|
|users.sapsys.gid|gid for the sapsys group|no (although null is allowed)|
|users.sapadm.uid|uid for the \<sap\>adm|no (although null is allowed)|
|abap_pas_hostname | pas server hostname for abap stack | yes (for solaman java installtion)| 
|abap_pas_instanceno | pas server instanceno for abap stack | yes (for solaman java installtion)| 
|sap.use_media_cd | use media CD paths | no |


### group variables (db)
|variable|info|required?|
|---|---|---|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|
|sybase.sybmgmtdbDataDeviceFolder|folder name for sybase mgmt data device|yes (only for sybase database)|
|sybase.sybmgmtdbLogDeviceFolder|folder name for sybase mgmt log device|yes (only for sybase database)|
|sybase.sybmgmtdbDeviceSize|size for sybase mgmt data device|yes (only for sybase database)|
|sybase.sybmgmtdbLogDeviceSize|size for sybase mgmt log device|yes (only for sybase databas)|
|sybase.sybsystemprocsDeviceSize|size for sybase systemproc device|yes (only for sybase database)|
|sybase.sizeMasterDatabase|size for sybase master device|yes (only for sybase database)|
|sybase.sizeSystemdbDatabase|size for sybase systemdb device|yes (only for sybase database)|
|sybase.sizeTempdb|size for sybase tempdb device|yes (only for sybase database)|
|sybase.databaseDevices[loopindex].device|name of the device|yes (only for sybase database)|
|sybase.databaseDevices[loopindex].folder|name of the folder|yes (only for sybase database)|
|sybase.databaseDevices[loopindex].size|size of the file|yes (only for sybase database)|
|sybase.databaseDevices[loopindex].filename|name of the file|yes (only for sybase database)|
|hdb_extractlocation|path where the zip file will be exported|no|

### group variables (content server)
|content_server.sapdataFolder|sapdataFolder|no(defaults to associated "sapdata" value)|
|content_server.saplogFolder|saplogFolder|no(defaults to associated "saplog" value)|
|content_server.adminSecurityGroup|adminSecurityGroup|no(defaults to associated "sapsys" value)|
|content_server.csHTTPPort|csHTTPPort|no(defaults to associated "1090" value)|
|content_server.csHTTPSPort|csHTTPSPort|no(defaults to associated "1091" value)|
|content_server.csHTTPScript|csHTTPScript|no(defaults to associated "/sapcs" value)|

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/playbooks/04_hana.yml)

## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/inventory)

## Checks
To validate that HANA is up and running, you can run the following command:
```bash
sapcontrol -nr <instance_number> -function GetProcessList
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References 
[Cloud Builder Developer Team design]

* added BW4 HANA (BW4HANA20.CORE.HDB.CP) product details in sapinst.params.j2
* parameterized HDB_Software_Dialogs.useMediaCD attribute ( default value is set to false )
* adding UME configuration attributes that are required for solman systems.
* looping contruct added to dynmaically adde SAPINST.CD.EXP parameters based on the location of LABEL*.ASC files in directory.
* changing abap_schema_name anad java_schema_name  to just a single variable schema_name defined under sap.db.
* adding arguments for webdispacher installation.
NW_webdispatcher_Instance.msHost = 
NW_webdispatcher_Instance.backEndSID = 
* uncommenting the below argument for pas hdbuserstore value.
HDB_Userstore.doNotResolveHostnames = {{ sap.logical_hosts.db.hostname | default() }}
* adding few below arguments for oracle installation.
storageBasedCopy.ora.listenerName = {{ sap.db.listener | default() }}
ora.rbDatabase = CREATEDB
* modifying the media location parametrized while installing SAP.
* parameterized SYB.NW_DBClient.databaseSoftwarePackage attribute value (default was set to /usr/sap/sapinst/SYBASE/51053549_1.ZIP)
* paramterized the values of SAPINST_START_GUI and SAPINST_START_GUISERVER with variable sapinst_enable_gui: "{{ sapinst_start_gui | default(false) }}" based on https://launchpad.support.sap.com/#/notes/2230669 .
* added input values required for webdispatcher and scm optimizer.
* parameterizing the /usr/sap into install_dir for various directory option.
* added parameter for sybase installation.
1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-90
