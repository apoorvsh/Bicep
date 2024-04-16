@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Getting Resource Id of Data Subnet for synapse Private Endpoint')
param dataSubnetRef string
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
@description('Existing Azure Synapse Private Link Hub Private DNS Zone')
param existingSynapseLinkHubPrivateDnsZoneId string

@description('Synapse Private Link Hub Name')
var privateLinkHubName = toLower('synw${projectCode}${environment}linkhub01')
@description('Synapse Private Link Hub Private Endpoint Name')
var synLinkHubPrivateEndpointName = toLower('pep-${projectCode}-${environment}-link-hub01')
@description('Network Interface Name for Synapse Private Link Hub')
var synLinkHubCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}linkhub01')
@description('Target Sub Resource for Private Link Hub')
var groupId = 'web'
var sysLinkHubPrivateDnsZoneName = 'privatelink.azuresynapse.net'
var sysLinkHubPvtEndpointDnsGroupName = '${synLinkHubPrivateEndpointName}/mydnsgroupname'

resource synapsePrivateLinkHub 'Microsoft.Synapse/privateLinkHubs@2021-06-01' = {
  name: privateLinkHubName
  location: location
  tags: union({
      Name: privateLinkHubName
    }, combineResourceTags)
  properties: {}
}

// creation of synapse private Link Hub Private Endpoint
resource synLinkHubPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: synLinkHubPrivateEndpointName
  location: location
  tags: union({
      Name: synLinkHubPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: synLinkHubPrivateEndpointName
        properties: {
          privateLinkServiceId: synapsePrivateLinkHub.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: synLinkHubCustomNetworkInterfaceName
    subnet: {
      id: dataSubnetRef
    }
  }
}

resource sysLinkHubPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: sysLinkHubPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: sysLinkHubPrivateDnsZoneName
    }, combineResourceTags)
}

resource sysLinkHubPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: sysLinkHubPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource sysLinkHubPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: sysLinkHubPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? sysLinkHubPrivateDnsZone.id : existingSynapseLinkHubPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    synLinkHubPrivateEndpoint
  ]
}
