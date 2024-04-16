@description('Private DNS Zone ID required')
param privateDnsZoneID array
param privateEndpointName array

resource privatEndpoints 'Microsoft.Network/privateEndpoints@2022-09-01' existing = [for i in range(0, length(privateEndpointName)): {
  name: privateEndpointName[i]
}]

@batchSize(1)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = [for i in range(0, length(privateEndpointName)): {
  name: privateEndpointName[i]
  parent: privatEndpoints[i]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneID[i]
        }
      }
    ]
  }
}]
