sap-win-get-os-command-outputs
=========

This role establish connection to windows systems for os level commands invocation and There are few OS informations are extracting from ansible gather facts.

Overview
------------
The configuration of sap-win-get-os-command-outputs involves a number of steps (at a high level):

  - Create output folder in controller node to store os outputs.
  - Following are the tasks fetching os details from gather facts and generating json files through       j2 template. These are : 1. OS version 2. Capture CPU memory.
  - Following are the tasks fetching OS details invoking respective in-line commands and generating json files through j2 template. These are: disk layout, java version etc.. 
  - Transfer profile and host files from target node to controller node
 
There are few pre-steps need to be performed before Ansible can communicate with a Microsoft Windows host.

  - Upgrading PowerShell and .NET Framework : Ansible requires PowerShell version 3.0 and .NET Framework 4.0 or newer to function on older 
					      operating systems like Server 2008 and Windows 7
  - WinRM Setup : WinRM service to be configured so that Ansible can connect to it. There are two main components of the WinRM service that 
		  governs how Ansible can interface with the Windows host: the listener and the service configuration settings.
 

Role Variables
--------------
The variables to be used within this role are all defined at group_vars or host_vars level

group_vars
-----------------------------------------
|varible|default|required?|
|---|---|---|
|sid||Y|

host_vars
----------------------------------------
|varible|default|required?|
|---|---|---|
|ansible_host||Y|
|ansible_user||Y|
|ansible_password||Y|
|ansible_port||Y|
|ansible_connection||Y|
|ansible_winrm_scheme||Y|
|ansible_winrm_server_cert_validation||Y|


Dependencies
------------

Ansible windows remote host connection will work only when winrm modules installed in controller machine and winrm configuration should be done in target nodes.

[Winrm setup guide](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html)

Example Playbook
----------------


    - hosts: servers
      gather_facts: true
      vars:
        ansible_become: false
      roles:
         - sap-get-db-queries-outputs


License
-------

Accenture use only

Author Information
------------------

[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)



## References 
[Cloud Builder Developer Team design]


1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-847