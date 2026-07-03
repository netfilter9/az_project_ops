# Ansible Role: win-ad-user


## Summary
This role is a wrapper for the Ansible module; win_domain_user
The functionality added by this wrapper allows for the creation of one or more domain user accounts from a dictionary input variable.

There are no defaults for this role.

## Prerequisites
The following variables have to be defined at the inventory or playbook level for this role to function:

| Parameter               | Description                                                                                                                                                                                                           |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| domain_fqdn             | The FQDN of the domain interacted with AD                                                                                                                                                                             |
| domain_ansible_username | The username to use when interacting with AD                                                                                                                                                                          |
| domain_ansible_password | The password to use when interacting with AD                                                                                                                                                                          |
| domain_controller       | Specifies the Active Directory Domain Services instance to connect to.<br>Can be in the form of an FQDN or NetBIOS name.<br>If not specified then the value is based on the domain of the computer running PowerShell |

## How to use
The role loops through a name dictionary object specified in the inventory vars.

```yaml
domain_users:
  sidadm:
    username: "{{ sap.sid|lower }}adm"
    password: "{{ vault_passwords.sap.sidadm }}"
  sidservice:
    username: "{{ sap.sid|lower }}Service"
    password: "{{ vault_passwords.sap.service }}"
```

## Reference
Ansible documentation for win_domain_user can be found here:
https://docs.ansible.com/ansible/latest/modules/win_domain_user_module.html