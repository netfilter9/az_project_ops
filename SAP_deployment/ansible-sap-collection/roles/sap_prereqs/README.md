# sap-prereqs
This role helps to start/stop any service in the machine and also sets some recommeded kernel parameters for all sap systems

## Overview
There are no specific pre-requisites for this role.
1. It will start/stop specified service in the machine.
2. It will set certain linux kernel parameters.

## Role variables
The variables to be used within this role are all defined at group_vars or host_vars level

### group variables (common)
|variable|info|required?|
|---|---|---|
|services[os_family]|an array of service to be start or stop|No|
|services[os_family][loopindex].name|name of the service|No|
|services[os_family][loopindex].state|options : started,stopped,restarted,reloaded |No| 
|services[os_family][loopindex].enabled|yes/no Whether the service should start on reboot.|No| 
|kernel_parameters[os_family][loopindex].name| Linux Kernel parameter Name |No| 
|services[os_family][loopindex].value| Linux kernel parameter value |No| 

List of services required to configure by default on RedHat machine is mentioned in defaults/main.yml
List of recommended kernel parameters required on all sap systems by default on RedHat machine and SUSE is mentioned in defaults/main.yml

## Example playbook
See: [Examples Repo]
Ticket Reference : https://alm.accenture.com/jira/browse/ACNCSSPR-175

## Checks
```Check with the command...
service firewalld status
It should show status of firewalld service

cat /etc/sysctl.conf
It should show the linux kernel parameters.

```
## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

# Design
[Cloud Builder Developer Team design]

1. Ticket reference: https://alm.accenture.com/jira/browse/ACNCSSPR-338
