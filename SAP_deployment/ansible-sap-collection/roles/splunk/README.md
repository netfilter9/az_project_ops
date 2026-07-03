# splunk
This role is used to install Splunk Universal Forwarder on a linux VM .

## Overview
The installation of Splunk UF involves a number of steps (at a high level):

* unarchive the installer file to /opt directory on the host Server. 
* cleanup the installer file from remote host
* set the deployment server using command /opt/splunkforwarder/bin/splunk set deploy-poll <xxx.xxx.xxx.xxx>:<port_number>
* set the user credential with admin role.
* enable boot-start for Splunk UF service 
* start splunk UF service 

## Role variables
|variable|info|required?|
|---|---|---|
|splunk.src|splunk UF installer file location|yes|
|splunk.server|IP of the deployment server|yes|
|splunk.port|port number|yes| 

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - splunk
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-936
