// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Specify a region for resource deployment.')
param location string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Existing Event Hub Private DNS Zone')
param existingEventHubPrivateDnsZoneId string
@description('Queue Private Dns Zone Id')
param queuePrivateDnsZoneId string
@description('Blob Private Dns Zone Id')
param blobPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewAccountPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewPortalPrivateDnsZoneId string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string

// parmaeter
@description(' Web Subnet Id for Prviate Endpoint')
param subnetRef string

// variables
@description('Specify a name for the Azure Purview account.')
var purviewName = toLower('pview-${projectCode}-${environment}-purview01')
@description('Azure Purview Private Endpoint Name on Account')
var azurePurviewAccountPrivateEndpointName = toLower('pep-${projectCode}-${environment}-account01')
@description('Network Interface Name for Purview Private Endpoint')
var accountCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}account01')
@description('Azure Purview Private Endpoint Name on Portal')
var azurePurviewPortalPrivateEndpointName = toLower('pep-${projectCode}-${environment}-portal01')
@description('Network Interface Name for Purview Private Endpoint')
var portalCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}portal01')
var managedResourceGroupName = 'managed-rg-${purviewName}'
@description('Target Sub Resource of Azure Purview')
var accountGroupId = 'account'
@description('Target Sub Resource of Azure Purview')
var portalGroupId = 'portal'
@description('Purview SKU Name')
var skuName = 'Standard'
@description('Purview SKU Capacity')
var skuCapacity = 1
@description('Public Network Access of Purview')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
var pviewAccountPrivateDnsZoneName = 'privatelink.purview.azure.com'
var pviewAccountPvtEndpointDnsGroupName = '${azurePurviewAccountPrivateEndpointName}/mydnsgroupname'
var pviewPortalPrivateDnsZoneName = 'privatelink.purviewstudio.azure.com'
var pviewPortalPvtEndpointDnsGroupName = '${azurePurviewPortalPrivateEndpointName}/mydnsgroupname'

// creation of microsoft purview account
resource purview 'Microsoft.Purview/accounts@2020-12-01-preview' = {
  name: purviewName
  location: location
  tags: union({
      Name: purviewName
    }, combineResourceTags)
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    managedResourceGroupName: managedResourceGroupName
  }
}

// creation of purview private endpoint for account
resource azurePurviewAccountprivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: azurePurviewAccountPrivateEndpointName
  location: location
  tags: union({
      Name: azurePurviewAccountPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: azurePurviewAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: purview.id
          groupIds: [
            accountGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: accountCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource pviewAccountPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: pviewAccountPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: pviewAccountPrivateDnsZoneName
    }, combineResourceTags)
}

resource pviewAccountPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: pviewAccountPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pviewAccountPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pviewAccountPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? pviewAccountPrivateDnsZone.id : existingPviewAccountPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    azurePurviewAccountprivateEndpoint
  ]
}

// creation of purview private endpoint for portal
resource azurePurviewPortalprivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: azurePurviewPortalPrivateEndpointName
  location: location
  tags: union({
      Name: azurePurviewPortalPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: azurePurviewPortalPrivateEndpointName
        properties: {
          privateLinkServiceId: purview.id
          groupIds: [
            portalGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: portalCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource pviewPortalPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: pviewPortalPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: pviewPortalPrivateDnsZoneName
    }, combineResourceTags)
}

resource pviewPortalPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: pviewPortalPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pviewPortalPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pviewPortalPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? pviewPortalPrivateDnsZone.id : existingPviewPortalPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    azurePurviewPortalprivateEndpoint
  ]
}

module purviewIngestion 'purview_ingestion_pv.bicep' = if (networkAccessApproach == 'Private') {
  name: 'purviewIngestionPv'
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    managedStorageAccountName: purview.properties.managedResources.storageAccount
    purviewManagedRgEventHubsNamespaceId: purview.properties.managedResources.eventHubNamespace
    subnetRef: subnetRef
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: vnetId
    vnetName: vnetName
    blobPrivateDnsZoneId: blobPrivateDnsZoneId
    queuePrivateDnsZoneId: queuePrivateDnsZoneId
    existingEventHubPrivateDnsZoneId: existingEventHubPrivateDnsZoneId
  }
}

// outputs ids of purview resources that automatically deployed when creating purview and used to create purview ingestion private endpoints 
// No needed 
output managedStorageAccountNameId string = purview.properties.managedResources.storageAccount
output purviewManagedRgEventHubsNamespaceId string = purview.properties.managedResources.eventHubNamespace
output managedResourceGroupId string = purview.properties.managedResources.resourceGroup
