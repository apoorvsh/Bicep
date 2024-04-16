@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@allowed([
  'Training'
  'Prediction'
])
param customVisionType string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Cognitive Serivce Private DNS Zone Id')
param existingCognitiveServicePrivateDnsZoneId string
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool
@description('Vnet Address Space')
param vnetAddressSpace string
@description('subnet address Prefix')
param subnetAddressPrefix string

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Private Endpoint Subnet Name')
var subnetName = toLower('sub-${projectCode}-${environment}-pv01')
@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name')
var cognitiveServiceName = toLower('cg${projectCode}-${environment}-customVision01')
@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name')
var customDomainName = toLower('cg${projectCode}-${environment}-customVision01')
/*@allowed([
  'S0'
  'F0'
])*/
var sku = 'S0'
@description('Form Recoginzer Public Access')
var publicNetworkAccess = networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(false) ? 'Disabled' : 'Enabled'
var networkAcls = {
  bypass: 'AzureServices'
  virtualNetworkRules: [
    {
      id: subnet.id
      action: 'Allow'
    }
  ]
  ipRules: []
  defaultAction: 'Deny'
}
@description('Key Vault Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-customVision01')
@description('Network Interface Name for Key Vault Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}customVision01')
var groupId = 'account'
var privateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var customVisionKind = {
  Training: {
    name: 'CustomVision.Training'
  }
  Prediction: {
    name: 'CustomVision.Prediction'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
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

// creation of subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.CognitiveServices'
      }
    ]
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: cognitiveServiceName
  location: location
  tags: union({
      Name: cognitiveServiceName
    }, combineResourceTags)
  sku: {
    name: sku
  }
  kind: customVisionKind[customVisionType].name
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(true) ? networkAcls : null
    customSubDomainName: customDomainName
    restore: cognitiveServiceRestore
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

// creation of custom vision private endpoint 
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: privateEndpointName
  location: location
  tags: union({
      Name: privateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: cognitiveService.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
    subnet: {
      id: subnet.id
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: privateDnsZoneName
    }, combineResourceTags)
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: privateDnsZone
  name: '${virtualNetwork.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingCognitiveServicePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

output privateDnsZoneId string = privateDnsZone.id
