# Ansible Role: win-azcopy


## Summary
This role is a custom wrapper for installing and downloading with AzCopy on Windows systems. It requires an outbound internet connection to download the 

There are two tasks in this role;

1. 01-install.yml - Checks if AzCopy is installed and added to system PATH. If not, it is downloaded and configured. This task always runs.
2. 02-download.yml - Conditional task which is run when a "{{ downloads.url }}" variable is defined.

There are no defaults for this role.

## Prerequisites
This role requires an outbound internet connection to download AzCopy from the Microsoft CDN.

## How to use
To ensure AzCopy is installed on a Windows system, call this role in a playbook:

```yaml
- hosts: host_group
  roles:
    - win-azcopy
```

To download from Azure Storage Blobs, a "downloads" dictionary object must be specified in the inventory vars.

```yaml
downloads:
  download_drive: E
  urls: 
    - url: "https://URLtoBlobDataContent/Example"
      token_ref: "token1"
      dest: "SilentInstall"
```