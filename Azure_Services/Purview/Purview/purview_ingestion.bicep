// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Location of Purview Ingestion Private Endpoint')
param location string
@description('Combine Resource Tags')
param combineResourceTags object
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Queue Private Dns Zone Id')
param queuePrivateDnsZoneId string
@description('Blob Private Dns Zone Id')
param blobPrivateDnsZoneId string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Event Hub Private DNS Zone')
param existingEventHubPrivateDnsZoneId string

// parameters
@description('Referencing Event Hub Namespace Id created by purview')
param purviewManagedRgEventHubsNamespaceId string
@description('Referencing storage account Id create by purview')
param managedStorageAccountName string
@description('Referencing Web Subnet Id ')
param subnetRef string

// variables
@description('Private Endpoint Name of Blob Storage Account')
var blobIngestionPrivateEndpointName = toLower('pep-${projectCode}-${environment}-ingestion01-blob')
@description('Network Interface Name for Purview Ingestion Private Endpoint')
var blobCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}ingestion01blob')
@description('Private Endpoint Name of Queue Storage Account')
var queueIngestionPrivateendpointName = toLower('pep-${projectCode}-${environment}-ingestion01-queue')
@description('Network Interface Name for Purview Ingestion Private Endpoint')
var queueCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}ingestion01queue')
@description('Private Endpoint Name of Event Hub')
var eventHubPrivateEndpointName = toLower('pep-${projectCode}-${environment}-ingestion01-namespace')
@description('Network Interface Name for Purview Ingestion Private Endpoint')
var namespaceCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}ingestion01namespace')
@description('Target Sub Resource of purview ingestion private endpoint')
var blobGroupId = 'blob'
@description('Target Sub Resource of purview ingestion private endpoint')
var queueGroupId = 'queue'
@description('Target Sub Resource of purview ingestion private endpoint')
var namespaceGroupId = 'namespace'
var blobPrivateDnsZoneName = 'privatelink.blob.${az.environment().suffixes.storage}'
var eventHubPrivateDnsZoneName = 'privatelink.servicebus.windows.net'
var blobPvtEndpointDnsGroupName = '${blobIngestionPrivateEndpointName}/mydnsgroupname'
var queuePvtEndpointDnsGroupName = '${queueIngestionPrivateendpointName}/mydnsgroupname'
var eventHubPvtEndpointDnsGroupName = '${eventHubPrivateEndpointName}/mydnsgroupname'
var queuePrivateDnsZoneName = 'privatelink.queue.${az.environment().suffixes.storage}'

// creation of purview ingestion private endpoint for blob
resource ingestionEndpointName_blob 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: blobIngestionPrivateEndpointName
  location: location
  tags: union({
      Name: blobIngestionPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobIngestionPrivateEndpointName
        properties: {
          privateLinkServiceId: managedStorageAccountName
          groupIds: [
            blobGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: blobCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  name: blobPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: blobPrivateDnsZoneName
    }, combineResourceTags)
}

resource blobPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  parent: blobPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource blobPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: blobPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? blobPrivateDnsZone.id : blobPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    ingestionEndpointName_blob
  ]
}

// creation of purview ingestion private endpoint for queue
resource ingestionEndpointName_queue 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: queueIngestionPrivateendpointName
  location: location
  tags: union({
      Name: queueIngestionPrivateendpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: queueIngestionPrivateendpointName
        properties: {
          privateLinkServiceId: managedStorageAccountName
          groupIds: [
            queueGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: queueCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  name: queuePrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: queuePrivateDnsZoneName
    }, combineResourceTags)
}

resource queuePrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  parent: queuePrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource queuePvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: queuePvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? queuePrivateDnsZone.id : queuePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    ingestionEndpointName_queue
  ]
}

// creation of purview ingestion private endpoint for evnet hub namespace
resource ingestionEndpointName_namespace 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: eventHubPrivateEndpointName
  location: location
  tags: union({
      Name: eventHubPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: eventHubPrivateEndpointName
        properties: {
          privateLinkServiceId: purviewManagedRgEventHubsNamespaceId
          groupIds: [
            namespaceGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: namespaceCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource eventHubPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  name: eventHubPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: eventHubPrivateDnsZoneName
    }, combineResourceTags)
}

resource eventHubPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated') {
  parent: eventHubPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource eventHubPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: eventHubPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? eventHubPrivateDnsZone.id : existingEventHubPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    ingestionEndpointName_namespace
  ]
}
