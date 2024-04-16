param purviewAccountName string
param managedResourceGroupName string
param vnetName string
param vnetAddressPrefix array
param subnetName string
param subnetAddressPrefix string
param location string
param purviewEndpointName array
param groupIDs array
param privateDNSZoneName array


resource vnet 'Microsoft.Network/virtualnetworks@2022-09-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefix
    }
  }
}

resource vnetName_subnet 'Microsoft.Network/virtualnetworks/subnets@2022-09-01' = {
  parent: vnet
  name: subnetName
  
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

resource purviewAccount 'Microsoft.Purview/accounts@2021-07-01' = {
  name: purviewAccountName
  location: location
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    cloudConnectors: {}
    managedResourceGroupName: managedResourceGroupName
    publicNetworkAccess: 'Disabled'
  }
}

resource purviewEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [ for i in range(0,5): {
  location: location
  name: purviewEndpointName[i]
  properties: {
    subnet: {
      id: vnetName_subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: purviewEndpointName[i]
        properties: {
          privateLinkServiceId: i<2 ? purviewAccount.id : i<4 ? purviewAccount.properties.managedResources.storageAccount : purviewAccount.properties.managedResources.eventHubNamespace //purviewAccount.id
          groupIds: [
            groupIDs[i]
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'accountNic${i}'
  }
  dependsOn: [

    vnet
  ]
}]

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01' = [for i in range(0,5):{
  location: 'global'
  name: privateDNSZoneName[i]
  properties: {}
  dependsOn: [
    vnet
  ]
}]

resource privateDNSZoneName_privateDNSZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = [ for i in range(0,5): {
  parent: privateDNSZone[i]
  name: '${privateDNSZoneName[i]}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}]

resource purviewEndpointName_mydnsgroupname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [ for i in range(0, 5):{
  parent: purviewEndpoint[i]
  name: 'mydnsgroupname${i}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config${i}'
        properties: {
          privateDnsZoneId: privateDNSZone[i].id
        }
      }
    ]
  }
}]

