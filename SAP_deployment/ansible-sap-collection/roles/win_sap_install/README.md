# win-sap-install

This role acts a a wrapper to the `sapinst.exe` executable that controls the installation of SAP.

# known issue

There is a known issue with the SAP installation on Windows whereby the initial installation attempt fails.  The symptoms of the problem are that the following is logged in the `sapinst.log`:

```
The step AddPrivileges with step key |NW_ABAP_ASCS|ind|ind|ind|ind|0|0|NW_First_Steps|ind|ind|ind|ind|firstSteps|0|Preinstall|ind|ind|ind|ind|Preinstall|0|AddPrivileges was executed with status ERROR. Reason: The step has requested the termination of the service execution.
```
When the above is logged the `sapinst` process does not terminate and the ansible installation of SAP does not continue.  This role has checks in place to detect this issue and terminate the process and subsequently retry the operation.  This is based on the original logic of the cloud builder DSC installation code.

An example playbook for win domain join may look like this:

```yaml

- name: join windows workgroup servers to a domain
  hosts: ascs
  gather_facts: yes
  roles:
    - win-sap-install
```

## Role variables
The variables to be used within this role are all defined at group level.

### group variables (windows)
There are two variables that have to be defined that the `win_sap_install` role requires (and are not defaulted):

| variable                       | description                                                      | type |
|--------------------------------| -----------------------------------------------------------------|------|
| `win_sap_install_arguments`    | command line arguments to be passed to `sapinst.exe`             | str  |
| `win_sap_install_sapinst_path` | full path to where `sapinst.exe` is located on the target server | str  |

### role variables
Refer to inline annotation in `defaults/main.yml`

### example execution
The code below shows an extract from the `roles/sap-ascs-standalone` role showing where the command line arguments are constructed in the `win_sap_install_arguments` variable along with a reference to the path to the `sapinst.exe` declared in `win_sap_install_sapinst_path`

```
- name: ensure ascs logs folder is present
  win_file:
    path: F:\SilentInstall\ASCSLogs
    state: directory

- name: set sapinst command line arguments
  set_fact:
    win_sap_install_arguments: >-
      SAPINST_INPUT_PARAMETERS_URL=F:\SilentInstall\ASCSInifile.params
      SAPINST_CWD=F:\SilentInstall\ASCSLogs
      SAPINST_EXECUTE_PRODUCT_ID={{ sap.product_id.ascs }}
      SAPINST_SKIP_DIALOGS=true
      SAPINST_START_GUISERVER=false
      SAPINST_START_GUI=false

- name: add virtual hostname to parameters if set
  set_fact:
    win_sap_install_arguments: "{{ win_sap_install_arguments +
                                ' SAPINST_USE_HOSTNAME=' + infra.ascs.virtual_hostname }}"
  when:
    - infra.ascs.virtual_hostname is defined
    - infra.ascs.virtual_hostname | length

- name: debug win_sap_install_arguments
  debug:
    var: win_sap_install_arguments

- name: install sap
  include_role:
    name: win-sap-install
  vars:
    win_sap_install_sapinst_path: F:\SilentInstall\SWPM10SP24\sapinst.exe
```

## License
Accenture use only

## Author Information
[Cloud Builder Team](https://alm.accenture.com/wiki/x/09AbFw)

## Design
[Cloud Builder Developer Team design]

1. INI changes for multiple export locations to be added as win-sap-install

Reference: https://alm.accenture.com/jira/browse/ACNCSSPR-155

