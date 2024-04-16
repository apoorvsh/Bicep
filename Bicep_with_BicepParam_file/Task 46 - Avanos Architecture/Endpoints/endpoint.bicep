param values object 
param subnetId string
param linkServiceIds array
param dnsId array



@batchSize(1)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [ for i in range (0,values.endpointCount):  {
  name: values.privateEndpointName[i]
  location: values.location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: values.linkServiceName[i]
        properties: {
          privateLinkServiceId: linkServiceIds[i]
          groupIds: [
            values.groupIds[i]
          ]
        }
      }
      
    ]
    customNetworkInterfaceName: values.nicInterfaceName[i]
  }
 
}]


@batchSize(1)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [ for i in range (0,values.endpointCount): {
  name: values.privateDNSZoneGroupName[i]
  parent: privateEndpoint[i]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: dnsId[i]
        }
      }
    ]
  }
  
}]

