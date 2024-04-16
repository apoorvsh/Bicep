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
@description('Referencing Databricks Nsg Id')
param databricksNsgRef string
@description('Databricks Host Subnet Address Prefix')
param databricksHostSubnetAddressPrefix string
@description('Datbricks Container Subnet Name')
param databricksContainerSubentAddressPrefix string

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Data Subnet Name')
var dataSubnetName = toLower('sub-${projectCode}-${environment}-data01')
@description('Databricks Host Subnet Name')
var databricksHostSubnetName = toLower('sub-${projectCode}-${environment}-dbwhost01')
@description('Databricks Container Subnet Name')
var databricksContainerSubnetName = toLower('sub-${projectCode}-${environment}-dbwcontainer01')
@description('Service Endpoint for Host and Container Subnets')
var storageServiceEndpoint = 'Microsoft.Storage'
@description('Service Endpoint for Key Vault')
var keyVaultServiceEndpoint = 'Microsoft.KeyVault'
var vnetName = newOrExisting == 'New' ? newVnetName : existingVnetName
@description('Service Endpoint for Host and Container Subnets')
var sqlServiceEndpoint = 'Microsoft.Sql'
@description('Service Endpoint for Host and Container Subnets')
var activeDirectoryServiceEndpoint = 'Microsoft.AzureActiveDirectory'

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

// creation of  databricks host subnet
resource databricksHostSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${databricksHostSubnetName}'
  dependsOn: [
    newVirtualNetwork, dataSubnet
  ]
  properties: {
    addressPrefix: databricksHostSubnetAddressPrefix
    networkSecurityGroup: {
      id: databricksNsgRef
    }
    delegations: [
      {
        name: 'databricks-del-public'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
    serviceEndpoints: [
      {
        service: storageServiceEndpoint
      }
      {
        service: activeDirectoryServiceEndpoint
      }
      {
        service: sqlServiceEndpoint
      }
    ]
  }
}

// creation of databrciks container subnet
resource databricksContainerSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${databricksContainerSubnetName}'
  dependsOn: [
    databricksHostSubnet, newVirtualNetwork, dataSubnet
  ]
  properties: {
    addressPrefix: databricksContainerSubentAddressPrefix
    networkSecurityGroup: {
      id: databricksNsgRef
    }
    delegations: [
      {
        name: 'databricks-del-private'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
    serviceEndpoints: [
      {
        service: storageServiceEndpoint
      }
      {
        service: activeDirectoryServiceEndpoint
      }
      {
        service: sqlServiceEndpoint
      }
    ]
  }
}

// output subnets is use in multiple biceps file for creating private endpoints
output existingVnetId string = existingVirtualNetwork.id
output newVnetId string = newVirtualNetwork.id
output dataSubnetId string = dataSubnet.id
output databricksHostSubnetId string = databricksHostSubnet.id
output databricksContainerSubnetId string = databricksContainerSubnet.id
output databricksHostSubnetName string = databricksHostSubnetName
output databricksContainerSubnetName string = databricksContainerSubnetName
output newVnetName string = newVirtualNetwork.name
