param values object
param devVnetID string


resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: values.hubVnetName
}

resource SourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  '${values.hubVnetName}To${values.name}'                                                       
  parent: hubVnet                                                                                                
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
       id: devVnetID
    }
  }
}
