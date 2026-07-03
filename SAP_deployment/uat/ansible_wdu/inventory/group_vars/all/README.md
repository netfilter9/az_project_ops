# Note
The example vault.yml is encrypted with the password "Accenture01" - please use something more secure for actual customer client secrets 

# Key commands
Create a vault file
```bash
ansible-vault create vault.yml
```

Edit a vault file
```bash
ansible-vault edit vault.yml
```

Encrypt and existing file
```bash
ansible-vault encrypt vault.yml
```

Running ansible commands which need to access the secrets, just add
```bash
--ask-vault-pass
```

Read more: https://docs.ansible.com/ansible/latest/user_guide/vault.html