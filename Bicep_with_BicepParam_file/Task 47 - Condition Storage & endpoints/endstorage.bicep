param vnetName string
param location string
param addressPrefix string
param subnetName string
param subnetPrefix string
param storageAccountName string
param storageAccountSku string
param kind string
param accessTier string
@allowed([
  'Endpoint'
  'NEndpoint'
])
param condition string
param endpointName string
param linkServiceName string
param groupId string
param nicName string
param defaultAction string
param bypass string
param privateDNSZoneName string
param dnsZoneLinkName string
param dnsGroupName string
param dnsZoneConfigName string



resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         addressPrefix
       ]
     }
  }  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetName
  parent: vnet
  properties: {
     addressPrefix: subnetPrefix
  }
} 

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
      defaultAction: defaultAction
       bypass: bypass

    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (condition=='Endpoint') {
  name: endpointName 
  location: location
  properties: {
     subnet: {
       id: subnet.id
     }
     privateLinkServiceConnections: [
       {
         name: linkServiceName
         properties: {
           privateLinkServiceId: storageAccount.id
           groupIds: [
            groupId
           ] 
         }  
       }
     ] 
     customNetworkInterfaceName: nicName  
  }  
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = if(condition=='Endpoint')  {
  name: privateDNSZoneName
  location: 'global'

}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = if(condition=='Endpoint') {
  name: dnsZoneLinkName
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id 
    }
  }
 
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = if(condition=='Endpoint') {
  name: dnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dnsZoneConfigName
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  
}
