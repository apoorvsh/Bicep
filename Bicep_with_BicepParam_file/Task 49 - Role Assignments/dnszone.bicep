param values object 
param vnetId string

@batchSize(1)
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = [ for i in range (0,values.count):{
  name: values.privateDNSZoneName[i]
  location: 'global'

}]

@batchSize(1)
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =[ for i in range (0,values.count): {
  name: values.privateDnsZoneLinkName[i]
  parent: privateDnsZone[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
 
}]


output adfDns string = privateDnsZone[0].id
output queueDns string = privateDnsZone[1].id
output adlsDns string = privateDnsZone[2].id
output blobDns string = privateDnsZone[3].id
output fileDns string = privateDnsZone[4].id
output tableDns string = privateDnsZone[5].id
