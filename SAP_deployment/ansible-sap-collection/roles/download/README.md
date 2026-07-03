# download
This role downloads the software on a VM .

## Overview
The download of software involves a number of steps (at a high level):

* get the source and destination details.
* connect to Azure storage account with SAS token.
* downloads the required Softwares.

## Role variables
|variable|info|required?|
|---|---|---|
|downloads.url|Source details of the blob|yes|
|downloads.token|SAS token to be defined on ansible vault|yes|
|downloads.dest|destination path|yes| 

## Example playbook
```yaml
---
- hosts: myserver
  roles:
    - download
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-864
