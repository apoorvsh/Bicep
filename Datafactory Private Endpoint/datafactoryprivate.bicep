param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param adfName string
param datafactoryTagName object
param privateEndpointName string
param privateEndpointTagName object
param privateLinkServiceConnectionsName string
param dnsZoneName string
param dnsZoneTagName object
param dnsZoneLocation string
param vnetLinkLocation string
param adfPrivate string
param groupID string
param registrationEnabled bool

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }  
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01'={
  name: subnetName
  parent: virtualNetwork
  location: resourceGroup().location
  properties:{
    addressPrefix: subnetAddress
  }
}

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' ={
  name: adfName
  location : resourceGroup().location
  tags: datafactoryTagName.tagA
  properties: {
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: resourceGroup().location
  tags: privateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: datafactory.id
          groupIds: [
            groupID
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: dnsZoneLocation
  tags: dnsZoneTagName.tagA  
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnszone.name}/${dnszone.name}-link'
  location: vnetLinkLocation
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: adfPrivate
        properties: {
          privateDnsZoneId: dnszone.id
        }
      }
    ]
  }
}
