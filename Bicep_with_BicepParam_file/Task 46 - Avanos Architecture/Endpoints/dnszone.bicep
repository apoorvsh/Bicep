param values object = {
 privateDNSZoneName: 'array'
 vnetId: 'string' 
 privateDnsZoneLinkName: 'array'
 count: 'int'
}


@batchSize(1)
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = [ for i in range (0,values.dnsCount):{
  name: values.privateDNSZoneName[i]
  location: 'global'

}]

@batchSize(1)
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =[ for i in range (0,values.dnsCount): {
  name: values.privateDnsZoneLinkName[i]
  parent: privateDnsZone[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: values.vnetId
    }
  }
 
}]


output adfDns string = privateDnsZone[0].id
output vaultDns string = privateDnsZone[1].id
output adlsDns string = privateDnsZone[2].id
output synapseDns string = privateDnsZone[3].id
