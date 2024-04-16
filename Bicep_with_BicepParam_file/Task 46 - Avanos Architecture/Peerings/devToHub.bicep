param values object
param hubVnetID string


resource devVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: values.name
}

resource SourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  '${values.name}To${values.hubVnetName}'                                                       
  parent: devVnet                                                                                                
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
       id: hubVnetID
    }
  }
}
