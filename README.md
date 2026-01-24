#Last-Update: 1/17/26
# AZ-104 Azure Administrator Labs

Hands-on Azure infrastructure labs designed to fully cover the
Microsoft AZ-104 Azure Administrator exam objectives.

This project focuses on real-world Azure administration scenarios
including networking, compute, storage, monitoring, and security.

## Architecture Overview
The lab deploys a complete Azure environment using ARM Templates:
- Virtual Network with multiple subnets
- Network Security Group (NSG)
- Windows Server Virtual Machine
- Public IP & Network Interface
- Storage Account
- Log Analytics Workspace

## Skills Covered
- Azure Virtual Machines (Deploy, Resize, Manage)
- Azure Networking (VNET, Subnets, NSG)
- Azure Storage (Blob, File, Access Keys)
- Azure Monitoring & Log Analytics
- ARM Templates (IaC)
- RBAC & Resource Governance

## Deployment
```bash
az deployment group create \
  --resource-group Lab1-privateDNS-BetweenTwoSubnet.JASON
