# hana_db
This role installs the base HANA software on a VM .
This role installs the base HANA software along with hanacockpit(optional) on a VM


## Overview
The installation and configuration of HANA software involves a number of steps (at a high level):

* install required pacakages for specific OS.
* Tweak grub file entries
* creating hana config file
* Install HANA software

## Role variables
The variables to be used within this role are all defined at group_vars levels.

### group variables (all)
|variable|info|required?|
|---|---|---|
|passwords.admin|password for the standard os admin user|yes|
|passwords.master|master password for HANA install|yes|
|passwords.sapadm|password for the sapadm user|yes|
|passwords.system|password for system user|yes|
|sap.db.sid|SID of the HANA install|yes|
|sap.instance_numbers.hana|instance number for the HANA instance|yes|
|users.dbsidadm.uid|uid for the \<dbsid\>adm user|yes (although null is allowed)|
|users.sapsys.gid|gid for the sapsys group|no (although null is allowed)|
|sap.db.cockpit.components | db components to install | no | 
|sap.db.cockpit.org_name | org_name | no | 
|sap.db.cockpit.org_manager_user | org manager user name  | no | 
|sap.db.cockpit.org_manager_password | org manager password | no  | 
|sap.db.hostagent_upgarde|boolean input for hostagent upgarde|no (input will be true if you want to upgarde host agent) |
|hostagent|name of the folder where we can put the host agent upgarde file|no (Default value is 'HOSTAGENT') |



### group variables (db)
|variable|info|required?|
|---|---|---|
|node1|reference for the first cluster node|yes|
|node2|reference for second cluster node|yes|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - hana-db
```
## Example inventory
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/sc05-s4-hana-suse-ha/ansible/inventory)

## Checks
To validate that HANA is up and running, you can run the following command:
```bash
sapcontrol -nr <instance_number> -function GetProcessList
```
To validate that HANA Cockpit is up and running (if installed ) you can go the below url in browser and check:
```bash
https://<dbvirtualhostname>:51028
https://<dbvirtualhostname>:51030

```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* rename the anf parameter to hana_scale_out
* replace the anf parameter with hana_scale_out in hana_install.config.j2
* enable firewall and set up the allowed ports in scaleout_config.yml
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-72
* rename the anf parameter to hana_scale_out
* replace the anf parameter with hana_scale_out in hana_install.config.j2
* enable firewall and set up the allowed ports in scaleout_config.yml
* add the ability to install hana cockpit along with normal hana db software . This requires 
     * Supplying hana cockpit related inputs in all.yml in below format under sap.db 
```bash
       cockpit:
          components: "server,xs,cockpit"
          org_name: "HANACockpit"
          org_manager_user: "COCKPIT_ADMIN"
          org_manager_password: "{{ passwords.org_manager_password}}"
          prod_space_name: "cockpit"
         
```
 
* creating a new hana cockpit configuration file which is used only when sap.db.cockpit is defined in all.yml.
* Providing the abaility to turn off the creation of default hana db tenant by specifying the below parameter in db section

```bash
       db:
          create_initial_tenant: false        
```
     
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-72
* modifying the sysctl configuration with below parameters for better performance.
```bash
      net.ipv4.tcp_syncookies = 1
      net.ipv4.conf.default.secure_redirects = 0
      net.ipv4.conf.all.secure_redirects = 0
```
* modifying the hdblcm_output_{{ ansible_date_time.iso8601 }}.log file to {{ sap.db.sid|lower }}_hdblcm_output_{{ ansible_date_time.iso8601 }}.log as its needed during hana software installation for multiple dbsid.

* adding pre & post configurations for anf mounted hana VMs.
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-72

* changes in pre & post configuration for anf mounted hana VMs.
* Fixed sap.filesystem undefined error
* Changed password authentication to yes in prehanadb config for hana scale out
* Changed password authentication to no in posthanadb config for hana scale out
* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-72