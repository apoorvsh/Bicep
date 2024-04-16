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
@description('Web Subent Address Prefix')
param webSubnetAddressPrefix string
@description('Data Subnet Address Prefix')
param dataSubnetAddressPrefix string
@description('Compute Subnet Address Prefix')
param computeSubnetAddressPrefix string
@description('Databricks Host Subnet Address Prefix')
param databricksHostSubnetAddressPrefix string
@description('App Subnet Address Prefix')
param appSubnetAddressPrefix string
@description('Datbricks Container Subnet Name')
param databricksContainerSubentAddressPrefix string
@description('Location for all Resources')
param location string
@description('Vnet is already deployed or user want to create new Vnet')
@allowed([ 'New', 'Existing' ])
param newOrExisting string
@description('Log Analytics Workspace Resource ID')
param workspaceId string

// parameters
@description('Referencing compute Nsg Id')
param computeNsgRef string
@description('Referencing web Nsg Id')
param webNsgRef string
@description('Referencing data Nsg Id')
param dataNsgRef string
@description('Referencing app Nsg Id')
param appNsgRef string
@description('Referencing Databricks Nsg Id')
param databricksNsgRef string
@description('Referencing compute Route Id')
param computeSubnetRouteRef string
@description('Referencing host Route Id')
param hostSubnetRouteRef string
@description('Referencing container Route Id')
param containerSubnetRouteRef string
@description('Referencing App Route Id')
param appSubnetRouteRef string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Web Subnet Name')
var webSubnetName = toLower('sub-${projectCode}-${environment}-web01')
@description('Data Subnet Name')
var dataSubnetName = toLower('sub-${projectCode}-${environment}-data01')
@description('Compute Subnet Name')
var computeSubnetName = toLower('sub-${projectCode}-${environment}-compute01')
@description('Databricks Host Subnet Name')
var databricksHostSubnetName = toLower('sub-${projectCode}-${environment}-dbwhost01')
@description('Databricks Container Subnet Name')
var databricksContainerSubnetName = toLower('sub-${projectCode}-${environment}-dbwcontainer01')
@description('App Subnet Name')
var appSubnetName = toLower('sub-${projectCode}-${environment}-App01')
@description('Service Endpoint for Host and Container Subnets')
var storageServiceEndpoint = 'Microsoft.Storage'
@description('Service Endpoint for Host and Container Subnets')
var sqlServiceEndpoint = 'Microsoft.Sql'
@description('Service Endpoint for Key Vault')
var keyVaultServiceEndpoint = 'Microsoft.KeyVault'
@description('Service Endpoint for Host and Container Subnets')
var activeDirectoryServiceEndpoint = 'Microsoft.AzureActiveDirectory'
@description('Service Endpoint for Web')
var webServiceEndpoint = 'Microsoft.Web'
@description('Service Endpoint for Cognitive Service')
var cognitiveServiceEndpoint = 'Microsoft.CognitiveServices'
var vnetName = newOrExisting == 'New' ? newVnetName : existingVnetName
var settingName = 'Send to Log Analytics Workspace'
var routeId = {
  routeConfig: {
    computeRouteId: computeSubnetRouteRef == 'Public' ? null : json('{"id": "${computeSubnetRouteRef}"}')
    dbwHostRouteId: hostSubnetRouteRef == 'Public' ? null : json('{"id": "${hostSubnetRouteRef}"}')
    dbwConRouteId: containerSubnetRouteRef == 'Public' ? null : json('{"id": "${containerSubnetRouteRef}"}')
    appRouteId: appSubnetRouteRef == 'Public' ? null : json('{"id": "${appSubnetRouteRef}"}')
  }
}

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

// creation of web subnet
resource webSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${webSubnetName}'
  dependsOn: [
    newVirtualNetwork
  ]
  properties: {
    addressPrefix: webSubnetAddressPrefix
    networkSecurityGroup: {
      id: webNsgRef
    }
  }
}

// creation of data subnet
resource dataSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${dataSubnetName}'
  dependsOn: [
    webSubnet, newVirtualNetwork
  ]
  properties: {
    addressPrefix: dataSubnetAddressPrefix
    networkSecurityGroup: {
      id: dataNsgRef
    }
    serviceEndpoints: [
      {
        service: storageServiceEndpoint
      }
      {
        service: keyVaultServiceEndpoint
      }
      {
        service: cognitiveServiceEndpoint
      }
    ]
  }
}

// creation of compute subnet
resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${computeSubnetName}'
  dependsOn: [
    dataSubnet, newVirtualNetwork
  ]
  properties: {
    addressPrefix: computeSubnetAddressPrefix
    networkSecurityGroup: {
      id: computeNsgRef
    }
    routeTable: routeId.routeConfig.computeRouteId
  }
}

// creation of  databricks host subnet
resource databricksHostSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${databricksHostSubnetName}'
  dependsOn: [
    computeSubnet, newVirtualNetwork
  ]
  properties: {
    addressPrefix: databricksHostSubnetAddressPrefix
    networkSecurityGroup: {
      id: databricksNsgRef
    }
    routeTable: routeId.routeConfig.dbwHostRouteId
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
    databricksHostSubnet, newVirtualNetwork
  ]
  properties: {
    addressPrefix: databricksContainerSubentAddressPrefix
    networkSecurityGroup: {
      id: databricksNsgRef
    }
    routeTable: routeId.routeConfig.dbwConRouteId
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

// creation of  databricks host subnet
resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${vnetName}/${appSubnetName}'
  dependsOn: [
    databricksContainerSubnet, newVirtualNetwork
  ]
  properties: {
    addressPrefix: appSubnetAddressPrefix
    networkSecurityGroup: {
      id: appNsgRef
    }
    routeTable: routeId.routeConfig.appRouteId
    delegations: [
      {
        name: 'delegation-serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
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
      {
        service: webServiceEndpoint
      }
    ]
  }
}

// Diagnostics Setting inside Azure Virtual Network
resource setting 'Microsoft.Network/virtualNetworks/providers/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: '${vnetName}/microsoft.insights/${settingName}'
  dependsOn: [
    newVirtualNetwork, existingVirtualNetwork
  ]
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

// output subnets is use in multiple biceps file for creating private endpoints
output existingVnetId string = existingVirtualNetwork.id
output newVnetId string = newVirtualNetwork.id
output webSubnetId string = webSubnet.id
output dataSubnetId string = dataSubnet.id
output computeSubnetId string = computeSubnet.id
output databricksHostSubnetId string = databricksHostSubnet.id
output databricksContainerSubnetId string = databricksContainerSubnet.id
output appSubnetId string = appSubnet.id
output databricksHostSubnetName string = databricksHostSubnetName
output databricksContainerSubnetName string = databricksContainerSubnetName
output newVnetName string = newVirtualNetwork.name
