sap-abap-execute-queries
=========

This role establish connection to an SAP system using ansible custom module(sap_pyrfc).
To perform the basis tasks for system migration using ABAP scripts.
it includes taking backup of system configurations and existing data for verification post migration

Requirements
------------
The installation and configuration of sap-abap-execute-queries involves a number of steps (at a high level):

  - Establish connection and getting output from SAP system
  - Storing outputs in a JSON format 
 
Custom module python scripts and ABAP scripts are included in role.
 

Role Variables
--------------
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (all)
|varible|default|required?|
|---|---|---|
|user||yes|
|password||yes|
|sap.sid|SID of the sap install|yes|
|sap.db.sid|SID of the HANA install|yes|
|client||yes|
|group||yes|
|input_params||yes|
|sap_type|type of SAP installed in system|yes|
|sap.db.type|type of db installed in system|yes|
|sap.instance_numbers.ascs|instance number for the ascs instance|yes|
|sap.instance_numbers.hana|instance number for the HANA instance|yes|
|sap.instance_numbers.pas|instance number for the pas instance|yes|
|sap.instance_numbers.aas|instance number for the aas instance|yes|
|abap_scripts_path||yes|
|outputs_path||yes|

Dependencies
------------

Ansible custom module(sap_pyrfc) will work only when "PyRFC - The Python RFC Connector" Python package installed in Ansible controller  machine.

[PyRFC Installation Guide](https://sap.github.io/PyRFC/install.html)

Example Playbook
----------------

    - hosts: localhost
      roles:
         - sap-abap-execute-queries

License
-------

Accenture use only

Author Information
------------------

[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References 
[Cloud Builder Developer Team design]


1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-68
