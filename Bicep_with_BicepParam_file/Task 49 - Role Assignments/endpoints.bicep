param values object 
param subnetId array
param linkServiceIds array
param dnsId array



@batchSize(1)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [ for i in range (0,values.count):  {
  name: values.privateEndpointName[i]
  location: values.location
  properties: {
    subnet: {
      id: i==0 ? subnetId[0] : subnetId[1]
    }
    privateLinkServiceConnections: [
      {
        name: values.linkServiceName[i]
        properties: {
          privateLinkServiceId:  i==0 ? linkServiceIds[0] : linkServiceIds[1]
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
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [ for i in range (0,values.count): {
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

