# win_disk_facts

This role is used to debug the disk facts.

# Overview

Pre-requisites for windows :

1. gets the disk facts
2. copyies the output in server
3. fetches the json file from server to remote_src

An example playbook for win domain join may look like this:

```yaml
- name: join windows workgroup servers to a domain
  hosts: ascs:mssql
  gather_facts: yes
  roles:
    - win_disk_facts
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1807


