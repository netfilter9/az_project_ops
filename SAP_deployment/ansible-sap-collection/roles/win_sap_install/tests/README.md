win_sap_install module testing
------------------------------

The playbook in this directory is used to test the `win_sap_install` anisble module using a [Test Double](https://martinfowler.com/bliki/TestDouble.html).  The actual SAP windows installation require a lot of supporting files and takes quite a while to perform.  To aid in development a mock `sapinst.exe` was created to produce the mimimum amount of functionality to recreate the functionality of the SAP installation process.  This allows for module development and testing without the need for any actual SAP installation files.

Refer to the notes in the `roles/win-sap-install/tests/test_win_sap.yml` playbook in this directory.  It can be run against any Windows system that is configured and accessible in the ansible inventory.  The playbook targets `hosts: windows` be fault but can be overridden with `-e target=my_windows_server` for example.

Ansible needs to know the bath to the module, this can be supplied at the beginning of the command line, for example:

```
ANSIBLE_LIBRARY=roles/win-sap-install/library ansible-playbook roles/win-sap-install/tests/test_win_sap.yml -e target=target=my_windows_server
```

Non-SAP command line inputs
---------------------------

The command line parameters `TEST_*` are just to control the behaviour of the mock `sapinst.exe` and are not part of the normal SAP command line syntax.

Prequisites
-----------

* a Windows system configured and accessible in the ansible inventory e.g. `ansible windows -m win_ping`
* Internet access to be able to download the `sapinst.exe` test doubel executable

author
------
anthony.skidmore@accenture.com