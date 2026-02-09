# Lab 05 – Secure a VM with Azure Virtual Network and NSG (AZ-104)

## 🎯 Objective
In this lab, you will:
- Create a Virtual Network (VNet) with two subnets
- Configure a Network Security Group (NSG) with inbound rules
- Deploy a Virtual Machine (VM) into a subnet
- Allow SSH/RDP access only from your public IP
- Validate allowed vs blocked traffic
- Clean up resources

This lab aligns with AZ-104 objectives: Virtual Networking, Security, and Compute.

---

## 🧰 Prerequisites
- An active Azure subscription
- Azure Portal access
- (Optional) Azure CLI installed and logged in: `az login`
- Your public IP address (https://whatismyipaddress.com)

---

## 🏗️ Architecture
- Resource Group: `rg-az104-lab05`
- VNet: `vnet-lab05 (10.0.0.0/16)`
- Subnets:
  - `web-subnet (10.0.1.0/24)`
  - `mgmt-subnet (10.0.2.0/24)`
- NSG: `nsg-web`
- VM: `vm-web-01`

---

## 🧪 Steps (Azure Portal)

### 1) Create Resource Group
Portal → Resource groups → Create  
Name: `rg-az104-lab05`  
Region: Choose your nearest region

### 2) Create Virtual Network with Two Subnets
Portal → Virtual networks → Create  
- Name: `vnet-lab05`
- Address space: `10.0.0.0/16`
- Subnets:
  - `web-subnet` – `10.0.1.0/24`
  - `mgmt-subnet` – `10.0.2.0/24`

### 3) Create NSG and Inbound Rules
Portal → Network security groups → Create  
Name: `nsg-web`

Add inbound rules:
- Allow SSH (Linux) **or** RDP (Windows) from **Your Public IP only**
  - Source: IP addresses
  - Source IP: `<YOUR_PUBLIC_IP>/32`
  - Port: 22 (SSH) or 3389 (RDP)
  - Action: Allow
- Deny All Inbound (default)

### 4) Associate NSG to Subnet
Open `nsg-web` → Subnets → Associate  
Select `vnet-lab05` → `web-subnet`

### 5) Deploy a VM into web-subnet
Portal → Virtual machines → Create  
- Name: `vm-web-01`
- Image: Ubuntu LTS (or Windows Server)
- Authentication: SSH key (Linux) or Password (Windows)
- Networking:
  - VNet: `vnet-lab05`
  - Subnet: `web-subnet`
  - Public IP: Enabled

### 6) Test Connectivity
- From your IP: SSH/RDP should work
- From another IP/device: Connection should be blocked

### 7) Clean Up (Important)
Delete resource group `rg-az104-lab05` to avoid charges.

---

## ⚙️ Steps (Azure CLI – Optional)

```bash
# Variables
RG=rg-az104-lab05
LOC=eastus
VNET=vnet-lab05
WEB_SUBNET=web-subnet
MGMT_SUBNET=mgmt-subnet
NSG=nsg-web
VM=vm-web-01
MYIP=<YOUR_PUBLIC_IP>/32

# Create RG
az group create -n $RG -l $LOC

# Create VNet + subnets
az network vnet create -g $RG -n $VNET --address-prefix 10.0.0.0/16 \
  --subnet-name $WEB_SUBNET --subnet-prefix 10.0.1.0/24

az network vnet subnet create -g $RG --vnet-name $VNET \
  -n $MGMT_SUBNET --address-prefixes 10.0.2.0/24

# Create NSG and rule
az network nsg create -g $RG -n $NSG
az network nsg rule create -g $RG --nsg-name $NSG -n allow-ssh-myip \
  --priority 1000 --source-address-prefixes $MYIP \
  --destination-port-ranges 22 --access Allow --protocol Tcp

# Associate NSG to web subnet
az network vnet subnet update -g $RG --vnet-name $VNET -n $WEB_SUBNET \
  --network-security-group $NSG

# Create VM (Linux example)
az vm create -g $RG -n $VM --image Ubuntu2204 \
  --vnet-name $VNET --subnet $WEB_SUBNET \
  --admin-username azureuser --generate-ssh-keys

# Clean up
az group delete -n $RG --yes --no-wait
