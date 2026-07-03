# hana_fast_restart
This role enables the hana-fast-restart feature in GCP for HANA DB VM. 

## Overview
The SAP HANA Fast Restart option uses storage in the file system to preserve and reuse MAIN data fragments to speed up SAP HANA restarts.
Here are the tasks mentioned below:
1. Check if the HDB version is greater than 2.00.40 so that hana fast restart can work.
2. Display the NUMA topology of your VM
3. Create the NUMA node directories.
4. Configure the tmpfs file system.
5. Mount the NUMA node directories to tmpfs.
6. Update /etc/fstab
7. SAP HANA configuration for Fast Restart 
  - Update the [persistence] section in the global.ini file
  - Update the [persistent_memory] sectionindexserver.ini file

## Role variables
The variables to be used within this role are all defined at all.yml .

### group variables
|variable|info|required?|
|---|---|---|
|platform|gcp|yes|
|sap.db.sid|db sid of the hana system|yes|
|sap.instance_numbers.db|db instance number of the hana system|yes|
|sap.db.memory_limit|memory_global_allocation_limit|yes|
|sap.db.default_table|can be on or default to change the default for new tables|yes|

## Checks
To validate that hana_fast_restart is working fine, you can run the following command:

HDB stop
HDB start

Check the trc file to see how much did the table took to finish reloading.

## License
Accenture use only

# Reference :
Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1810

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)