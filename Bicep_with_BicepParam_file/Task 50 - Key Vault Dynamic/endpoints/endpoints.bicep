param values object
param subnetID string
param keyVaultID string
param privateDnsZoneID string


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: values.privateEndpointName
  location: values.location
  properties: {
    subnet: {
      id: subnetID
    }
    privateLinkServiceConnections: [
      {
        name: values.privateEndpointLinkName
        properties: {
          privateLinkServiceId: keyVaultID
          groupIds: [
            values.groupID
          ]
        }
      }
    ]
    customNetworkInterfaceName: values.nicName
  }
 
}



resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: values.dnsGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneID
        }
      }
    ]
  }
  
}


