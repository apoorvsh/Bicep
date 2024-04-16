using './modenization.main.bicep'

param location = 'eastus2'
param resourceTags = {}
param environment = 'dev'
param domainName = 'appMod'
param resourceGroupName = 'dev-eu2-ai-aiservices-rg'
param vnetResourceGroupName = 'dev-eu2-ai-network-rg'
param vnetName = 'dev-eu2-ai-vnet01'
param pvSubnetName = 'dev-eu2-ai-snet-data01'
param networkAccessApproach = 'Public'
param acrSku = 'Premium'
param firewallIPEnable = 'Disable'
param image = 'apoorvacr.azurecr.io/hello-world:latest'
param cpu = 1
param memory = '1.5'
param osType = 'Linux'
param aciSku = 'Standard'
param ipPort = 80
param ipProtocol = 'TCP'
param privateZoneDnsID = []

