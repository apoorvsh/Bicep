param vnetName string
param vnetAddress string
param vnetTagName object
param subnetName string
param subnetAddress string
param synapseName string
param synapseTagName object
@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param storageAccountUrl string
param fileSystemName string
param privateEndpointName string
param privateEndpointTagName object
param privateLinkServiceConnectionsName string
param dnsZoneName string
param dnsZoneTagName object
param dnsZoneLocation string
param vnetLinkLocation string
param registrationEnabled bool
param synapsePrivateDnsZoneConfig string
 
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: resourceGroup().location
  tags: synapseTagName.tagA
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    defaultDataLakeStorage: {
      accountUrl: storageAccountUrl
      filesystem: fileSystemName
    }
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
          privateLinkServiceId: synapse.id
          groupIds: [
            'dev'
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
        name: synapsePrivateDnsZoneConfig
        properties: {
          privateDnsZoneId: dnszone.id
        }
      }
    ]
  }
}

