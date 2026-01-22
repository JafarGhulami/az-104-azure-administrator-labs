#!/bin/bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"

# ========== VARIABLES ==========
RG_JP="rg-japanwest"
RG_KR="rg-koreacentral"

LOC_JP="japanwest"
LOC_KR="koreacentral"

VM1="VM1-Ubuntu"
VM2="VM2-Ubuntu"

VNET1="VM1-Ubuntu-vnet"
VNET2="VM2-Ubuntu-vnet"

SUBNET="default"

NSG1="VM1-Ubuntu-nsg"
NSG2="VM2-Ubuntu-nsg"

PIP1="VM1-Ubuntu-ip"
PIP2="VM2-Ubuntu-ip"

NIC1="vm1-nic"
NIC2="vm2-nic"

ADMIN_USER="adminroot"

# ========== RESOURCE GROUPS ==========
az group create -n $RG_JP -l $LOC_JP
az group create -n $RG_KR -l $LOC_KR

# ========== NSG + RULES ==========
az network nsg create -g $RG_JP -n $NSG1 -l $LOC_JP
az network nsg create -g $RG_KR -n $NSG2 -l $LOC_KR

for PORT in 22 80 443
do
  az network nsg rule create \
    --resource-group $RG_JP \
    --nsg-name $NSG1 \
    --name allow-$PORT \
    --protocol Tcp \
    --priority $((300 + PORT)) \
    --destination-port-range $PORT \
    --access Allow

  az network nsg rule create \
    --resource-group $RG_KR \
    --nsg-name $NSG2 \
    --name allow-$PORT \
    --protocol Tcp \
    --priority $((300 + PORT)) \
    --destination-port-range $PORT \
    --access Allow
done

# ========== VNET + SUBNET ==========
az network vnet create \
  -g $RG_JP \
  -n $VNET1 \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET \
  --subnet-prefix 10.0.0.0/24

az network vnet create \
  -g $RG_KR \
  -n $VNET2 \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET \
  --subnet-prefix 10.0.0.0/24

# ========== PUBLIC IP ==========
az network public-ip create \
  -g $RG_JP \
  -n $PIP1 \
  --sku Standard \
  --allocation-method Static

az network public-ip create \
  -g $RG_KR \
  -n $PIP2 \
  --sku Standard \
  --allocation-method Static

# ========== NIC ==========
az network nic create \
  -g $RG_JP \
  -n $NIC1 \
  --vnet-name $VNET1 \
  --subnet $SUBNET \
  --network-security-group $NSG1 \
  --public-ip-address $PIP1

az network nic create \
  -g $RG_KR \
  -n $NIC2 \
  --vnet-name $VNET2 \
  --subnet $SUBNET \
  --network-security-group $NSG2 \
  --public-ip-address $PIP2

# ========== VM ==========
az vm create \
  -g $RG_JP \
  -n $VM1 \
  --nics $NIC1 \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys

az vm create \
  -g $RG_KR \
  -n $VM2 \
  --nics $NIC2 \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys
