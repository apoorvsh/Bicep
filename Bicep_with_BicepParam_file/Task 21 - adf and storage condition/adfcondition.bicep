
param privateEndpointName string = 'newendpoint'
param vnetName string  = 'VNET'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetName string = 'subnet'
param subnetAddressPrefix string = '10.0.0.0/18'

param dataFactoryName string = 'hemangtaskadfcondition'
param storageAccountName string = 'hemangtaskadfcondition'
param storageAccountSku string = 'Standard_LRS'
param location string = 'Central India'
param kind string = 'StorageV2'
param accessTier string = 'Hot'
@allowed( [
  'storage'
  'datafactory'
  ''
])
param privatelinkservice string





var groupID = privatelinkservice == 'storage' ? 'blob' : 'dataFactory'
var linknserviceID = privatelinkservice == 'storage' ? storageAccount.id : dataFactory.id

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:  [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetAddressPrefix
  }
  
}







resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: kind
  properties: {
    accessTier: accessTier
  }
}

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}









resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privatelinkservice
        properties: {
          privateLinkServiceId: linknserviceID
          groupIds: [
            groupID
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'HemangNic'
  }
 
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.vaultcore.azure.net'
  
  
  
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id 
    }
  }
 
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'mydnsgroupname'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  
}
