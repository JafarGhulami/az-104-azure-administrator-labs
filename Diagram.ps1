<#
.PROJECT
PROD-MONITOR Azure Infrastructure

.AUTHOR
Jafar Ghulami

.DESCRIPTION
This script provisions the core Azure infrastructure for:
- Monitoring VM
- Networking (VNet, NSG, Public IP)
- Azure App Service
- PostgreSQL Flexible Server
- Recovery Services Vault
#>

# ----------------------------------------------------
# Variables
# ----------------------------------------------------

$location = "koreasouth"
$resourceGroup = "RG-PROD-MONITOR"

$vnetName = "vnet-koreasouth"
$subnetName = "subnet-monitor"
$nsgName = "PROD-MONITOR-01-nsg"

$vmName = "PROD-MONITOR-01"
$vmSize = "Standard_B2s"

$appPlanName = "ASP-ReplicationLab-a575"
$appName = "JafarWebsite"

$postgresName = "jafarwebsite-server"
$backupVaultName = "PRD-DAL-RSV-BACKUP"

# ----------------------------------------------------
# Login & Resource Group
# ----------------------------------------------------

Connect-AzAccount

New-AzResourceGroup `
    -Name $resourceGroup `
    -Location $location

# ----------------------------------------------------
# Networking
# ----------------------------------------------------

# Create NSG
$nsg = New-AzNetworkSecurityGroup `
    -Name $nsgName `
    -ResourceGroupName $resourceGroup `
    -Location $location

# Create Subnet
$subnet = New-AzVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix "10.0.1.0/24" `
    -NetworkSecurityGroup $nsg

# Create VNet
$vnet = New-AzVirtualNetwork `
    -Name $vnetName `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet $subnet

# Public IP
$publicIp = New-AzPublicIpAddress `
    -Name "$vmName-ip" `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -AllocationMethod Static

# Network Interface
$nic = New-AzNetworkInterface `
    -Name "$vmName-nic" `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $publicIp.Id

# ----------------------------------------------------
# Virtual Machine
# ----------------------------------------------------

$cred = Get-Credential

$vmConfig = New-AzVMConfig `
    -VMName $vmName `
    -VMSize $vmSize |
    Set-AzVMOperatingSystem `
        -Linux `
        -ComputerName $vmName `
        -Credential $cred |
    Set-AzVMSourceImage `
        -PublisherName Canonical `
        -Offer UbuntuServer `
        -Skus 20_04-lts |
    Add-AzVMNetworkInterface `
        -Id $nic.Id

New-AzVM `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -VM $vmConfig

# ----------------------------------------------------
# App Service
# ----------------------------------------------------

$appPlan = New-AzAppServicePlan `
    -Name $appPlanName `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Tier Basic `
    -NumberofWorkers 1

New-AzWebApp `
    -Name $appName `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -AppServicePlan $appPlanName

# ----------------------------------------------------
# PostgreSQL Flexible Server
# ----------------------------------------------------

New-AzPostgreSqlFlexibleServer `
    -Name $postgresName `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -AdministratorLogin "pgadmin" `
    -AdministratorLoginPassword (Read-Host -AsSecureString "Postgres Password")

# ----------------------------------------------------
# Recovery Services Vault
# ----------------------------------------------------

New-AzRecoveryServicesVault `
    -Name $backupVaultName `
    -ResourceGroupName $resourceGroup `
    -Location $location
