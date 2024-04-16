// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Azure Data Factory (dataFactory) Private DNS Zone')
param existingDataFactoryPrivateDnsZoneId string
@description('Existing Azure Data Factory (Portal) Private DNS Zone')
param existingPortalAdfPrivateDnsZoneId string

// parameter
@description(' Data Subnet Id for Prviate Endpoint')
param subnetRef string

// variables
@description('Azure Data Factory Name')
var adfName = toLower('df-${projectCode}-${environment}-dp01')
@description('Azure Data Facotry SHIR Name')
var shirName = toLower('df-${projectCode}-${environment}-shir01')
@description('Azure Data Factory Private Endpoint Name')
var dataFactoryPrivateEndpointName = toLower('pep-${projectCode}-${environment}-datafactory01')
@description('Network Interface Name for Data Factory Private Endpoint')
var dataFactoryCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}datafactory01')
@description('Azure Data Factory Private Endpoint Name')
var portalAdfPrivateEndpointName = toLower('pep-${projectCode}-${environment}-portal01')
@description('Network Interface Name for Data Factory Private Endpoint')
var portalAdfCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}portal01')
@description('Target Sub Resource of Data Factory')
var dataFactoryGroupId = 'datafactory'
@description('Target Sub Resource of Data Factory')
var portalGroupId = 'portal'
@description('Azure Data Facotory Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
var dataFactoryPrivateDnsZoneName = 'privatelink.datafactory.azure.net'
var dataFactoryPvtEndpointDnsGroupName = '${dataFactoryPrivateEndpointName}/mydnsgroupname'
var portalAdfPrivateDnsZoneName = 'privatelink.adf.azure.com'
var portalAdfPvtEndpointDnsGroupName = '${portalAdfPrivateEndpointName}/mydnsgroupname'

// creation of azure data factory 
resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  location: location
  tags: union({
      Name: adfName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
  }
}

// creation of Self Hosted Integration Runtime inside Azure Data Factory
resource adfShir 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: shirName
  parent: datafactory
  properties: {
    description: 'Self Hosted Integration Runtime'
    type: 'SelfHosted'
    typeProperties: {
      /* linkedInfo: {
        authorizationType: 'string'
        // For remaining properties, see LinkedIntegrationRuntimeType objects
      }*/
    }
  }
}

// creation of azure data factory private endpoint (Data Factory)
resource dataFactoryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: dataFactoryPrivateEndpointName
  location: location
  tags: union({
      Name: dataFactoryPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: dataFactoryPrivateEndpointName
        properties: {
          privateLinkServiceId: datafactory.id
          groupIds: [
            dataFactoryGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: dataFactoryCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource dataFactoryPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: dataFactoryPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: dataFactoryPrivateDnsZoneName
    }, combineResourceTags)
}

resource dataFactoryPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: dataFactoryPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource dataFatoryPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: dataFactoryPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? dataFactoryPrivateDnsZone.id : existingDataFactoryPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    dataFactoryPrivateEndpoint
  ]
}

// creation of azure data factory private endpoint (Portal)
resource portalAdfPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: portalAdfPrivateEndpointName
  dependsOn: [
    dataFactoryPrivateEndpoint
  ]
  location: location
  tags: union({
      Name: portalAdfPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: portalAdfPrivateEndpointName
        properties: {
          privateLinkServiceId: datafactory.id
          groupIds: [
            portalGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: portalAdfCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource portalAdfPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: portalAdfPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: portalAdfPrivateDnsZoneName
    }, combineResourceTags)
}

resource portalAdfPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: portalAdfPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource portalAdfPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: portalAdfPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? portalAdfPrivateDnsZone.id : existingPortalAdfPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    portalAdfPrivateEndpoint
  ]
}

// output the object ID of azure data factory will use this in to add access policy in existing key vault
output adfIdentityPrincipalId string = datafactory.identity.principalId
