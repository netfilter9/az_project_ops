ansible-role-bastion-host
-------------------------

This is an ansible role designed for the post configuration of a bastion host after a [Terraform deployment](https://alm.accenture.com/wiki/display/IACHSTBU/How-to%3A+Execute+your+first+Terraform+deployment).  

The purpose of the role is to install required packages and create a `python3` virtual environment for running ansible.  The default version of `python` installed with CentOS 7.7 is `Python 2.7.5`.  However, python2 is now [deprecated](https://www.python.org/doc/sunset-python-2/) and it is advisable to use `python3` going forward.  As part of this role it will check that a minimum version of CentOS 7 is installed and if so it will install `python3` and configure a [virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) using the python `venv` module.  

Using a virtual environment has some benefits over installing pip packages at the system level using privilege escalation e.g. `sudo`.  For example:

* packages can be installed with pip using user-level privileges, this is better from a security point of view e.g. prevents setup code associated with a pip package being executed with root privileges
* keeps things separate from system level python packages
* easier to recover from if encountering python package/dependency type issues (just remove the virtual environment and run the role again)

### requirements

The role is based on the base system created by the [cloudbuilder packer template](https://innersource.accenture.com/projects/IASC/repos/cloudbuilder-examples/browse/azure/packer/bastion-sec.json).  Specifically for this role:

* CentOS 7.7 or greater
* Ansible installed at the system level
* user with passwordless sudo on the bastion host
* libselinux-python3 system package installed


### running the role remotely

The role can be run remotely (from a Windows Subsystem for Linux(WSL) for example).  Check that the inventory defined in `bastion/` matches that of the deployed bastion environment, if not update it accordingly.  Check that the definition of the ssh private key needed to access the bastion host in `bastion/host_vars/bastion.yml` is configured correctly, it defaults to `ansible_ssh_private_key_file: ~/.ssh/admin_accenture_id_rsa`.  After that run the following from the git repository root directory:

```
ansible-playbook playbooks/bastion-host.yml
```

Logout and login again and confirm that the `python3` virtual environment is as per [validating the python3 virtual environment](#validating-the-python3-virtual-environment)


### running the role locally

The role can also be ran directly on the bastion host itself assuming that ansible is installed already (which it is by default when using the [packer](https://www.packer.io/) built cloud image).  To run the role locally on the bastion host itself run the following commands when logged in as `admin_accenture`:

```
git clone ssh://git@innersource.accenture.com/iasc/ansible-windows-poc.git # or https://innersource.accenture.com/scm/iasc/ansible-windows-poc.git
cd ansible-windows-poc
ansible-playbook playbooks/bastion-host.yml -e target=localhost
```

Logout and login again and confirm that the `python3` virtual environment is as per [validating the python3 virtual environment](#validating-the-python3-virtual-environment)

### validating the python3 virtual environment
The above should have setup the python3 virtual environment and also, by default, added it to the `~/.bash_profile` of the `admin_accenture` user.  So, the next time that you login using that account the prompt should look like the below:

```
(ansible_bastion) [admin_accenture@bastion ~]$
```
The `(ansible_bastion)` element of the prompt shows that the virtual environment is active.  To investigate further enter the following commands and also review the example expected output:

```
(ansible_bastion) [admin_accenture@bastion ~]$ ansible --version
ansible 2.9.8
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/admin_accenture/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/share/py3_venvs/ansible_bastion/lib64/python3.6/site-packages/ansible
  executable location = /usr/local/share/py3_venvs/ansible_bastion/bin/ansible
  python version = 3.6.8 (default, Apr  2 2020, 13:34:55) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

*Note:*  
Notice that the python version is now `3.6.8`

```
(ansible_bastion) [admin_accenture@bastion ~]$ pip list
Package       Version
------------- ----------
ansible       2.9.10
certifi       2020.4.5.1
cffi          1.14.0
chardet       3.0.4
cryptography  2.9.2
idna          2.9
Jinja2        2.11.2
jmespath      0.10.0
MarkupSafe    1.1.1
ntlm-auth     1.4.0
pip           20.1
pycparser     2.20
pykerberos    1.2.1
pywinrm       0.4.1
PyYAML        5.3.1
requests      2.23.0
requests-ntlm 1.1.0
setuptools    39.2.0
six           1.14.0
urllib3       1.25.9
xmltodict     0.12.0
```

*Note:* to exit from the python virtual environment use the `deactivate` command.

### ansible python3 discovery

Even though we may have configured a python3 environment ansible will still perform it's own [interpreter discovery](https://docs.ansible.com/ansible/latest/reference_appendices/interpreter_discovery.html), which can result in still running `python2` when running an ansible playbook.  The simplest method of tuning this so that it picks up the python3 interpreter instead is to set `ansible_python_interpreter` to the path of the `VIRTUAL_ENV` environment variable value if present, or set to `auto_legacy` if not.  This is the default behavior for ansible prior to version `2.12`.  For this kind of dynamic behavior the `YAML` format inventory is required as opposed to the older `INI` style. For example, this can be done in the `hosts.yml` inventory file:

```
---

all:
  hosts:
    bastion:
      ansible_host: 10.0.1.4
      ansible_connection: local
      ansible_python_interpreter: "{{ lookup('env', 'VIRTUAL_ENV') |
                                      ternary(lookup('env','VIRTUAL_ENV') +
                                      '/bin/python','auto_legacy') }}"
  children:
    linux:
      hosts:
        bastion:
```
To test that we are indeed running in a python3 environment after making the above changes we can run a test playbook locally on the bastion host:
```
ansible-playbook roles/ansible-role-bastion-host/tests/test_python_environment.yml
```
The above will validate the python being used and will fail if python3 is not being used.


### managing the python3 virtual environment with requirements.txt

In the root of this repo is a `requirements.txt` file that defines the required python [pip](https://pip.pypa.io/en/stable/) packages.  As part of this role it processes this file to determine what packages are to be installed.  The content of the `requirements.txt` is not micro-managed to the extent that you would get if you used the [pip freeze](https://pip.pypa.io/en/stable/reference/pip_freeze/) command.  Rather, it defines some high-level requirements and relies on sub-dependencies to be installed automatically.  The version of ansible is pinned, for example `ansible==2.9.8`, this allows a known and tested version of ansible to be used with the codebase.  To update ansible going forward, the codebase should be tested with the intended target version and on successful testing the `requirements.txt` can be updated and ran for new deployments or for updating existing bastion hosts by pulling the latest commits and re-running this role to apply the updates.

From a high-level perspective this role does something like the following if performed at the command line:

```
sudo yum -y install python3
mkdir /usr/local/share/py3_venvs
python3 -m venv /usr/local/share/py3_venvs
source /usr/local/share/py3_venvs/ansible_bastion/bin/activate
pip install -r ./requirements.txt
echo "source /usr/local/share/py3_venvs/ansible_bastion/bin/activate" >> ~/.bash_profile
```

*Note:* the above is not exhaustive and is just for illustration purposes

### allowing other users read-only access to the virtual environment

Should other users other than the default administrator need to use the python virtual environment this could be allowed by creating a new user and adding to the group allowing access or by modifying an existing user as follows:

```
sudo usermod -aG ansible_bastion_venv_users ansible_user                                                              # add the example ansible_user to the default venv group
echo "source /usr/local/share/py3_venvs/ansible_bastion/bin/activate" | sudo tee -a /home/ansible_user/.bash_profile  # optionally load the venv automatically for the user

```
*Note:*  
Users added to this group will have read-only access and will not be able to amend the python virtual environment.

### recreating the python3 virtual environment

If a problem should occur for whatever reason with the virtual environment then it can simply be rebuilt by removing the entire directory i.e.
```
sudo rm -rf /usr/local/share/py3_venvs
```
and then re-running the role as defined in [running the role remotely](#running-the-role-remotely) or [running the role locally](#running-the-role-locally)


author
------
anthony.skidmore@accenture.com
