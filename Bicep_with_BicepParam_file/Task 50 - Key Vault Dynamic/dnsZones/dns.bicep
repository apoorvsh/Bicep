param values object
param vnetID string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: values.privateDNSZoneName
  location: 'global'
  
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: values.dnsZoneLinkName
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetID 
    }
  }
 
}

output dnsID string = privateDnsZone.id
