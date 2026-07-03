# win_sap_download

This role is used for downloading media.

## Overview
The role involves a number of steps :

* Downloads media for azure platform and installs azure cli client using win_azcopy role(for windows ).
* Downloads media for GCP platform using gsutil(for windows ).

## Example playbook

```yaml
---

- hosts: host_group
  roles:
    - win_sap_download
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Reference
[Cloud Builder Developer Team design]

* ticket reference : https://alm.accenture.com/jira/browse/ACNCSSPR-1777
