param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param sqlServerName string
param sqlServerTagName object
@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string
param sqlServerDatabaseName string
param sqlServerDatabaseTagName object
param collation string
param edition string
param requestedServiceObjectiveName string
param sqlServerPrivate string
param privateEndpointTagName object
param privateLinkServiceConnectionsName string
param groupID string
param dnsZoneName string
param location string
param dnsZoneTagName object
param registrationEnabled bool
param privateDnsZoneConfigsName string

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

resource sqlServer 'Microsoft.Sql/servers@2014-04-01' ={
  name: sqlServerName
  location: resourceGroup().location
  tags: sqlServerTagName.tagA
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2014-04-01' = {
  parent: sqlServer
  name: sqlServerDatabaseName
  location: resourceGroup().location
  tags: sqlServerDatabaseTagName.tagA
  properties: {
    collation: collation
    edition: edition
    requestedServiceObjectiveName: requestedServiceObjectiveName
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: sqlServerPrivate
  location: resourceGroup().location
  tags: privateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: sqlServer.id
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
  location: location
  tags: dnsZoneTagName.tagA
}
 
 
resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnszone.name}/${dnszone.name}-link'
  location: location
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
        name: privateDnsZoneConfigsName
        properties: {
          privateDnsZoneId: dnszone.id
        }
      }
    ]
  }
}
