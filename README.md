# Azure VMs Configuration Automation via Ansible

This repository demonstrates an end-to-end Infrastructure as Code (IaC) and Configuration Management workflow. It showcases the automated provisioning of cloud infrastructure in Microsoft Azure and the standardized configuration of multiple Linux distributions using Ansible roles.

## Project Overview

Managing configurations across different operating system flavors can introduce complexity and drift. This project solves that by separating the infrastructure provisioning from the OS-level configuration, ensuring a predictable, repeatable, and OS-agnostic deployment strategy.

The repository is split into two primary phases:
1. **Infrastructure Provisioning:** Deploying the foundational compute resources in Azure.
2. **Configuration Management:** Applying standardized settings across a heterogeneous Linux environment.

## ⚠️ Important Note: Lab vs. Production Environment

This repository is designed specifically as a **demonstration and lab project**. To simplify the deployment and focus on the core Ansible automation logic, a few intentional architectural adjustments were made that differ from strict enterprise production standards:

* **Authentication & Secrets:** For this lab, plaintext passwords are used within the configuration files to quickly bootstrap the environment. In a real-world production scenario, secrets would be securely fetched and managed using **Azure Key Vault**.
* **Code Structure:** The Terraform code is kept relatively flat and straightforward for readability. In a production environment, the infrastructure would be deployed using modularized Terraform structures with strict variable formatting and validation.
* **Network Access:** The Virtual Machines in this deployment are assigned **Public IPs** for direct, easy access over SSH during the demonstration. In a true enterprise setup, public IPs would be strictly prohibited, and access would be routed privately via Azure Bastion, VPN gateways, or ExpressRoute.
* **Images :** The images used for SUSE and Ubuntu are official Azure Marketplace Images which are free and for RHEL a third party publisher Rocky Linux 9 image is used. Refer code for more details.

## Repository Structure

### 1. `vms-terraform-deploy` (Infrastructure Provisioning)
This directory contains the Terraform configurations required to deploy the demonstration environment in Microsoft Azure. 

* **Purpose:** Automates the creation of 3 distinct Virtual Machines in Azure.
* **Environment:** Provisions VMs representing three major Linux families to test cross-compatibility.
* **More Details:** [Read the Terraform Deployment Documentation](./vms-terraform-deploy/README.md) 

### 2. `ansible-lab` (Configuration Management)
This directory houses the Ansible playbooks and roles used to configure the freshly deployed Azure VMs. 

* **Purpose:** Standardizes server configurations across different OS flavors (Debian, SUSE, and RedHat) using a single, unified Ansible codebase.
* **Key Features:** Utilizes Ansible roles to handle OS-specific package managers, service configurations (like SNMP), and user management dynamically based on the target node's OS family.
* **More Details:** [Read the Ansible Configuration Documentation](./ansible-lab/README.md) 

## Technologies Used
* **Cloud Provider:** Microsoft Azure
* **Infrastructure as Code:** Terraform
* **Configuration Management:** Ansible
* **Operating Systems:** Ubuntu/Debian, SLES (SUSE), RHEL (RedHat)

## 💡 Skills Demonstrated
This project serves as a practical demonstration of several core Cloud Engineering and DevOps competencies:
* **Infrastructure as Code (IaC):** Automating the repeatable provisioning of Azure networking and compute resources using Terraform.
* **Cross-Platform Configuration Management:** Designing idempotent, OS-agnostic Ansible roles that dynamically adapt to Debian, RHEL, and SUSE architectures using `ansible_os_family`.
* **Dynamic Inventory Handling:** Bridging the gap between infrastructure deployment and configuration management by dynamically injecting Terraform outputs (IPs) into Ansible inventories.
* **Security & Access Management:** Implementing encrypted secrets management via Ansible Vault, configuring custom firewalls (`ufw`/`firewalld`), and automating secure "breakglass" user access.

## 🚀 Future Enhancements (Roadmap)
While this repository establishes a solid baseline, the following enhancements are planned to expand its functionality and mirror a true enterprise-grade environment:
* **Role Expansion:** Developing and integrating dedicated Ansible roles for **Database (DB)** deployment, **Web Server** configuration, and **LVM disk management** to build on top of the existing `common` role.
