param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param storageName string 
param storageAccountTagName object
param kind string
param sku string
param accessTier string
param allowBlobPublicAccess bool
param allowSharedKeyAccess bool
param blobEnabled bool
param fileEnabled bool
param queueEnalbed bool
param tableEnabled bool
param storagePrivate string
param privateEndpointTagName object
param privateLinkServiceConnectionsName string
param dnsZoneName string
param dnsZoneTagName object
param location string
param registrationEnabled bool
param privateDnsZoneConfigsName string
param groupId string

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

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: resourceGroup().location
  tags: storageAccountTagName.tagA
  
  kind: kind
  sku: {
    name: sku
  }
  properties:{
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    services: {
        blob: {
          enabled: blobEnabled
          
        }
        file: {
          enabled: fileEnabled
         
        }
        queue: {
          enabled: queueEnalbed
         
        }
        table: {
          enabled: tableEnabled
          
        }
    }
  } 
}
  
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
    name: storagePrivate
    location: resourceGroup().location
    tags: privateEndpointTagName.tagA
    properties: {
      privateLinkServiceConnections: [
        {
          name: privateLinkServiceConnectionsName
          properties: {
            privateLinkServiceId: storageAccount.id
            groupIds: [
              groupId
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
 
  
