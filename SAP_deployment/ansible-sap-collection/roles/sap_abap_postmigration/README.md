sap-abap-postmigration
=========

This role establish connection to an SAP system using ansible custom module(sap_pyrfc).

To perform the basis tasks for post system migration using ABAP scripts.

This role also validate the source and target system configurations using ansible custom modules (sap_align_configuration, sap_httpurlloc, sap_rz21_segment, sap_logon_group_smlg, sap_rfc_groups)

Requirements
------------

Custom module python scripts and post migration related ABAP scripts are included in role.

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

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - sap-abap-postmigration

License
-------

Accenture use only

Author Information
------------------

[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References 
[Cloud Builder Developer Team design]


1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-825


