# Ansible Configuration Management Lab

This directory contains the Ansible playbooks and roles used to configure the three Azure Virtual Machines provisioned by Terraform. 


## What This Code Does
This setup uses a primary `common` role to dynamically apply standard configurations across Debian, RHEL, and SUSE distributions. 

Specifically, this automation:
1. **Dynamic Inventory Management:** The `local-host.yml` playbook runs locally to automatically update the control node's `/etc/hosts` file and the Ansible `inventory` file with the dynamic Azure Public IPs.
2. **OS-Specific Variable Loading:** Dynamically loads variables (like package names and config paths) based on the target OS family (`Debian.yml`, `RedHat.yml`, `Suse.yml`).
3. **System Standardization:** Deploys a custom MOTD (Message of the Day) and standardizes the bash prompt (`PS1`) for all users.
4. **Breakglass User Management:** Creates an `azadmin` user with an encrypted password and configures passwordless sudo access.
5. **Firewall Configuration:** Automatically detects the OS and opens UDP Port 161 using the native firewall tool (`ufw` for Debian, `firewalld` for RHEL/SUSE).
6. **SNMPv3 Setup:** Installs SNMP packages, safely stops the service, checks for existing users, creates an SNMPv3 user (with auth/priv credentials), removes default read-write users, and restarts the service using handlers.

## Directory Structure
```text
ansible-lab/
├── ansible.cfg                # Ansible configuration file
├── inventory                  # Dynamic inventory file (updated via playbook)
├── local-host.yml             # Playbook to update local hosts/inventory IPs
├── initial-config.yml         # Main playbook applying the 'common' role
├── common-commands.txt        # Reference commands
├── vars/
│   └── secrets.yml            # Ansible Vault encrypted file for passwords
└── roles/
    └── common/
        ├── defaults/
        ├── files/
        ├── handlers/
        │   └── main.yml       # Service restart handlers (snmpd, sshd)
        ├── tasks/
        │   └── main.yml       # Primary configuration logic
        ├── templates/
        │   └── motd.j2        # Jinja2 template for Message of the Day
        └── vars/
            ├── Debian.yml     # Ubuntu/Debian specific variables
            ├── RedHat.yml     # RHEL/Rocky specific variables
            ├── Suse.yml       # SLES specific variables
            └── main.yml
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
Ansible requires passwordless SSH access to the target nodes. Generate an SSH keypair on your control node:

```bash
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
```

*Note: The public key (`~/.ssh/id_rsa.pub`) generated here must be passed into the Terraform `cloud-init.yaml` during the initial infrastructure provisioning so it gets injected into the Azure VMs.*

### 3. Install Required Ansible Collections
This code relies on community and posix modules for firewall and system management. Install them using Ansible Galaxy:

```bash
ansible-galaxy collection install ansible.posix community.general
```

## Secrets Management
Passwords (such as the `azadmin` hash, and SNMP `auth_pass`/`priv_pass`) are **not** stored in plaintext. They are passed into the playbook via an encrypted Ansible Vault file located at `./vars/secrets.yml`. 

When running the main configuration playbook, you will be prompted for the vault password to decrypt these variables in memory.

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
