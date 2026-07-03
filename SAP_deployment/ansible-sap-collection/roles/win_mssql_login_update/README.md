# win-mssql-login-update

This role updates the  MSSQL login on database server.

# Overview

Following are the steps for updating mssql login details:

1. Spliting the domain name
2. Change the collation ID
3. Adding the domain user in the SQL Logins  
4. Selecting the server role(sysadmin)
5. Changing the log on for SQLSERVERAGENT Service on windows  with domain user
6. Setting service startup mode to auto and ensure it is started


An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: std
  gather_facts: yes
  roles:
    - win-mssql-login-update
```

## Example playbook
See: [Examples Repo](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/scenario124/ansible/playbooks)

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. New Role to be created as win-mssql-install

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-1302


