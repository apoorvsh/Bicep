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
@description('Existing Azure Automation Private Dns Zone id')
param existingAutomationPrivateDnsZoneId string
@description('Vnet Address Space')
param vnetAddressSpace string
@description('subnet address Prefix')
param subnetAddressPrefix string

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Private Endpoint Subnet Name')
var subnetName = toLower('sub-${projectCode}-${environment}-pv01')
var accountname = toLower('auto-${projectCode}-${environment}-account01')
var webHookPrivateEndpointName = toLower('pep-${projectCode}-${environment}-webhook01')
var hybridWorkerPrivateEndpointName = toLower('pep-${projectCode}-${environment}-hybridWorker01')
var webHookCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}webhook01')
var hybridWorkerCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}hybridworker01')
var webHookGroupId = 'Webhook'
var hybridWorkerGroupId = 'DSCAndHybridWorker'
@description('Automation Account Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? false : true
var disableLocalAuth = false
var sku = {
  capacity: null
  family: null
  name: 'Basic'
}
var privateDnsZoneName = 'privatelink.azure-automation.net'
var webHookPvtEndpointDnsGroupName = '${webHookPrivateEndpointName}/mydnsgroupname'
var hybridWorkerPvtEndpointDnsGroupName = '${hybridWorkerPrivateEndpointName}/mydnsgroupname'

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
  }
}

resource autaccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: accountname
  location: location
  tags: union({
      Name: accountname
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: disableLocalAuth
    encryption: {
      identity: {}
      keySource: 'Microsoft.Automation'
    }
    publicNetworkAccess: publicNetworkAccess
    sku: sku
  }
}

// creation of Azure Automation Account private endpoint
resource webHookPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: webHookPrivateEndpointName
  location: location
  tags: union({
      Name: webHookPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: webHookPrivateEndpointName
        properties: {
          privateLinkServiceId: autaccount.id
          groupIds: [
            webHookGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: webHookCustomNetworkInterfaceName
    subnet: {
      id: subnet.id
    }
  }
}

// creation of key vault private endpoint
resource hybridWorkerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: hybridWorkerPrivateEndpointName
  location: location
  tags: union({
      Name: hybridWorkerPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: webHookPrivateEndpointName
        properties: {
          privateLinkServiceId: autaccount.id
          groupIds: [
            hybridWorkerGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: hybridWorkerCustomNetworkInterfaceName
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

resource webHookPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: webHookPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingAutomationPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    webHookPrivateEndpoint
  ]
}

resource hybridWokerPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: hybridWorkerPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingAutomationPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    hybridWorkerPrivateEndpoint
  ]
}
