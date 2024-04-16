param storageAccountName string
param storageAccountSku string 
param location string
param kind string
param accessTier string
param privateEndpointName array 
param vnetName string 
param vnetAddressPrefix string 
param subnetName string 
param subnetAddressPrefix string  
param privateDNSZoneName array
param groupids array
param linkservicename array


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: kind
  properties: {
    isHnsEnabled: true
    accessTier: accessTier
    networkAcls: {
      defaultAction: 'Deny'
       bypass: 'AzureServices'

    }
  }
}

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}




resource vnet 'Microsoft.Network/virtualnetworks@2022-09-01' = {
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

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2022-09-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetAddressPrefix
  }
  
}



resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [ for i in range (0,5):  {
  name: privateEndpointName[i]
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: linkservicename[i]
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            groupids[i]
          ]
        }
      }
      
    ]
    customNetworkInterfaceName: 'HemangNic${i+1}'
  }
 
}]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = [ for i in range (0,5):{
  name: privateDNSZoneName[i]
  location: 'global'

}]

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =[ for i in range (0,5): {
  name: 'link${i+1}'
  parent: privateDnsZone[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id 
    }
  }
 
}]

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [ for i in range (0,5): {
  name: 'mydnsgroupname${i+1}'
  parent: privateEndpoint[i]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone[i].id
        }
      }
    ]
  }
  
}]



