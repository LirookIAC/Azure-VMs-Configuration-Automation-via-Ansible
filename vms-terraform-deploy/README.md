# Azure Infrastructure Provisioning with Terraform

This directory contains the Terraform configuration used to automatically provision the foundational Azure infrastructure required for the configuration management lab.



## What This Code Does
Briefly, this configuration deploys a complete, isolated network environment and spins up three distinct Linux virtual machines. Specifically, it creates:
* **1 Resource Group** (`example-resources`) in Central India.
* **1 Virtual Network & Subnet** (`10.0.3.0/24`).
* **1 Network Security Group (NSG)** with inbound rules allowing SSH (22), ICMP (Ping), and SNMP (161 UDP).
* **3 Virtual Machines** deployed via a `for_each` loop:
  * Ubuntu 24.04 LTS (Debian family)
  * Rocky Linux 9 (RHEL family)
  * SLES 15 SP5 (SUSE family)
* **Outputs** the Public and Private IPs of the generated VMs for easy access.

## ⚠️ Important Security Notice (Lab Environment)
**DO NOT use this code as-is for production environments.** This code is explicitly written for a demonstration/lab environment. The following design choices were made for simplicity and accessibility:
1. **Plaintext Passwords:** The VM admin password (`Password@1234`) is hardcoded in `main.tf`. In a real-world scenario, SSH keys would be used, and passwords/secrets would be dynamically fetched from **Azure Key Vault**.
2. **Public IP Addresses:** Every VM is assigned a Public IP for direct SSH access. In production, VMs should only have private IPs, and access should be routed through a secure entry point like Azure Bastion or a VPN Gateway.
3. **Hardcoded Subscription:** The `provider.tf` file contains a hardcoded subscription ID. In an enterprise setup, this would be passed dynamically via environment variables or CI/CD pipelines.

## Prerequisites
Before running this code, ensure you have the following installed:
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment Instructions

### 1. Authenticate with Azure
First, log in to your Azure account using the CLI:
```bash
az login


### 2. Set Your Subscription Context
Ensure you are operating within the correct Azure subscription (this should match the `subscription_id` defined in your `provider.tf`):
```bash
az account set --subscription "bed9c8b2-bb60-492d-92a9-d1641fb7adf8"
```

### 3. Initialize Terraform
Download the necessary Azure provider plugins:
```bash
terraform init
```

### 4. Review the Execution Plan
Verify what resources Terraform is going to create:
```bash
terraform plan
```

### 5. Deploy the Infrastructure
Apply the configuration to build the resources in Azure. You will need to type `yes` to confirm:
```bash
terraform apply
```
*(Note: You can use `terraform apply -auto-approve` to skip the confirmation prompt).*

### 6. Clean Up (Optional)
When you are done with the lab and want to avoid further Azure billing, destroy the resources:
```bash
terraform destroy
```
