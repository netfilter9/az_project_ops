# dpagent
This role installs DP Agent .

## Overview
The installs DP Agent(at a high level):

* installas required packages.
* changing owner and permission.
* install DP agent.

## Role variables
|variable|info|required?|
|---|---|---|
|agent_listener_port|agent listener port|no|
|agent_admin_port|agent admin port|no|
|install_dir|installation path|no|

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - dpagent
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-864