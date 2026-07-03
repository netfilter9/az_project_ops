sap-get-os-command-outputs
=========

This role establish connection to linux systems for os level commands invocation and there are few OS informations are extracting from gather facts.

Overview
------------
The configuration of get-os-commands-outputs involves a number of steps (at a high level):

  - Following are the tasks fetching os details from gather facts and generating json files through j2 template. 
    1. OS version 
    2. Capture CPU memory
  - Following are the tasks fetching OS details invoking respective in-line commands and generating json files through j2 template. 
     - disk layout, java version etc..
  - Transfer profile and host files from target node to controller node


Role Variables
--------------
The variables to be used within this role are all defined at group_vars or host_vars level

group_vars
-----------------------------------------
|varible|default|required?|
|---|---|---|
|sid|SID of the sap install|yes|
|sap_type|type of SAP installed in system|yes|

host_vars
-----------------------------------------
|varible|default|required?|
|---|---|---|
|os_export_path|os outputs export path


Example Playbook
----------------

    - hosts: servers
      roles:
         - sap-get-os-command-outputs


License
-------

Accenture use only

Author Information
------------------

[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## References 
[Cloud Builder Developer Team design]


1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-345
