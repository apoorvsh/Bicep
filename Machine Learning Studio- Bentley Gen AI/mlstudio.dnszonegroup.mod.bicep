@description('Private DNS Zone ID required')
param privateDnsZoneID array
param privateEndpointName string

resource privatEndpoints 'Microsoft.Network/privateEndpoints@2022-09-01' existing =  {
  name: privateEndpointName
}


resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: privateEndpointName
  parent: privatEndpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneID[0]
        }
      }
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: privateDnsZoneID[1]
        }
      }
    ]
  }
}
