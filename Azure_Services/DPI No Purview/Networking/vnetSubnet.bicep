// Global parameters
@description('Combine Resource Tags')
param combineResourceTags object
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Existing Virtual Network Name')
param existingVnetName string
@description('Vnet Address Space')
param vnetAddressSpace string
@description('Data Subnet Address Prefix')
param dataSubnetAddressPrefix string
@description('Location for all Resources')
param location string
@description('Vnet is already deployed or user want to create new Vnet')
@allowed([ 'New', 'Existing' ])
param newOrExisting string

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Data Subnet Name')
var dataSubnetName = toLower('sub-${projectCode}-${environment}-data01')
@description('Service Endpoint for Host and Container Subnets')
var storageServiceEndpoint = 'Microsoft.Storage'
@description('Service Endpoint for Key Vault')
var keyVaultServiceEndpoint = 'Microsoft.KeyVault'
var vnetName = newOrExisting == 'New' ? newVnetName : existingVnetName

// existing vnet that is already deployed on azure 
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (newOrExisting == 'Existing') {
  name: existingVnetName
}

resource newVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = if (newOrExisting == 'New') {
  name: newVnetName
  location: location
  tags: union({
      Name: newVnetName
    }, combineResourceTags)
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}

// creation of data subnet
resource dataSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${dataSubnetName}'
  dependsOn: [
    newVirtualNetwork
  ]
  properties: {
    addressPrefix: dataSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: storageServiceEndpoint
      }
      {
        service: keyVaultServiceEndpoint
      }
    ]
  }
}

// output subnets is use in multiple biceps file for creating private endpoints
output existingVnetId string = existingVirtualNetwork.id
output newVnetId string = newVirtualNetwork.id
output dataSubnetId string = dataSubnet.id
output newVnetName string = newVirtualNetwork.name
