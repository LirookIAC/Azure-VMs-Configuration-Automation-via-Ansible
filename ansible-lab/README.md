# Ansible Configuration Management Lab

This directory contains the Ansible playbooks and roles used to configure the three Azure Linux Virtual Machines accross flavours (Debian , SUSE and RedHat) provisioned by Terraform. 


## What This Code Does

This setup uses a primary `common` role to dynamically apply standard configurations across Debian, RHEL, and SUSE distributions. Specifically, this automation handles:

* ** Inventory Management:** The `local-host.yml` playbook runs locally to automatically update the control node's `/etc/hosts` file and the Ansible `inventory` file with the dynamic Azure Public IPs.
* **OS-Specific Variable Loading:** Dynamically loads variables (like package names and config paths) based on the target OS family (`Debian.yml`, `RedHat.yml`, `Suse.yml`).
* **System Standardization:** Deploys a custom MOTD (Message of the Day) and standardizes the bash prompt (PS1) for all users.
* **Breakglass User Management:** Creates an `azadmin` user with an encrypted password and configures passwordless sudo access.
* **Firewall Configuration:** Automatically detects the OS and opens UDP Port 161 using the native firewall tool (`ufw` for Debian, `firewalld` for RHEL/SUSE).
* **SNMPv3 Setup:** Installs SNMP packages, safely stops the service, checks for existing users, creates an SNMPv3 user (with auth/priv credentials), removes default read-write users, and restarts the service using handlers.
* **Automatic FS Setup:** Install necessay LVM File Systems and mount them persistently.

### Role Breakdown

* **`common`**: Handles the baseline configuration, system standardization, security hardening, user management, and SNMPv3 setup across all target distributions.
* **`common-lvm`**: Automates the complete storage management lifecycle, including the creation of Volume Groups (VG) and Logical Volumes (LV), filesystem formatting, and configuring persistent mount points.

## Directory Structure
```text
ansible-lab/
├── ansible.cfg                # Ansible configuration file
├── inventory                  # Dynamic inventory file
├── local-host.yml             # Playbook to update local hosts/inventory IPs
├── initial-config.yml         # Main playbook applying the 'common' role
├── common-commands.txt        # Reference commands
├── vars/
│   └── secrets.yml            # Ansible Vault encrypted file
└── roles/
    ├── common/                # Existing configuration role
    │   ├── defaults/
    │   ├── files/
    │   ├── handlers/
    │   │   └── main.yml
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── templates/
    │   │   └── motd.j2
    │   └── vars/
    │       ├── Debian.yml
    │       ├── RedHat.yml
    │       └── main.yml
    └── common-lvm/            # New LVM automation role
        ├── defaults/          # Default variables for VG/LV names
        ├── files/             # Static files (if any)
        ├── handlers/          # Handlers for mounting/unmounting
        ├── meta/              # Role metadata and dependencies
        ├── tasks/
        │   └── main.yml       # LVM, Filesystem, and Mount logic
        ├── templates/         # Jinja2 templates (e.g., fstab snippets)
        ├── tests/             # CI/CD test playbooks
        ├── vars/              # High-priority role variables
        └── README.md          # Documentation for this specific role
```
## Prerequisites: Control Node Setup

To run these playbooks, you must have a separate Linux machine acting as your **Ansible Control Node**. 

### 1. Install Ansible
On your dedicated control node, install Ansible:

**For Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install ansible -y
```

**For RHEL/Rocky:**
```bash
sudo dnf install epel-release -y
sudo dnf install ansible -y
```

### 2. Generate SSH Keys
Ansible requires passwordless SSH access to the target nodes. Generate an SSH keypair on your control node. Run below command and press enter to accept defaults:

```bash
ssh-keygen 
```

*Note: The public key (`~/.ssh/id_rsa.pub`) generated here must be passed into the Terraform `cloud-init.yaml` during the initial infrastructure provisioning so it gets injected into the Azure VMs.The idea here is to use SSH keys to authenticate seamlessly to all VMs.To do this  "private_key_file = $HOME/.ssh/id_rsa" is mentioned in your ansible.cfg.*

### 3. Install Required Ansible Collections
This code relies on community and posix modules for firewall and system management. Install them using Ansible Galaxy:

```bash
ansible-galaxy collection install ansible.posix community.general
```

## Secrets Management
Passwords (such as the `azadmin` hash, and SNMP `auth_pass`/`priv_pass`) are **not** stored in plaintext. They are passed into the playbook via an encrypted Ansible Vault file located at `./vars/secrets.yml`. 

When running the main configuration playbook, you will be prompted for the vault password to decrypt these variables in memory.The password is 'password'. Use ansible-vault to decrypt and view this file.Ideally you should create this yourself using ansible-vault.

## Deployment Instructions

### Step 1: Update IP Addresses
First, update the IPs in `local-host.yml` to match the outputs from your Terraform deployment. Then, run the playbook locally to inject those IPs into your inventory and `/etc/hosts` file:

```bash
ansible-playbook local-host.yml --ask-become-pass
```

### Step 2: Test Connectivity
Verify that your control node can communicate with the newly provisioned Azure VMs via SSH keys:

```bash
ansible azure_vms -m ping
```

### Step 3: Run the Configuration Playbook
Execute the main playbook to configure the VMs. You must pass the `--ask-vault-pass` flag to decrypt `secrets.yml`:

```bash
ansible-playbook initial-config.yml --ask-vault-pass
```
