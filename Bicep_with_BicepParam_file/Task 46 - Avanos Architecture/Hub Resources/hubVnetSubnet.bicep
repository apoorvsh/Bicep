param values object 







resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: values.hubVnetName
  location: values.hublocation
  properties: {
     addressSpace: {
       addressPrefixes: [
        values.vngAddressPrefix
       ]
     }
  }    
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: values.vngSubnetName
  parent: vnet
  properties: {
    addressPrefix: values.vngSubnetPrefix
  }  
}


/*resource SourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  '${existingVnetName}To${vnetname}'                                                       
  parent: existingVnet                                                                                                
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
       id: vnet.id
    }
  }
}*/


/*resource destinationToSourcePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${vnetname}To${existingVnetName}'                                                    
  parent: vnet                                                                                              
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: existingVnet.id
    }
  }
}*/



output hubVnetId string = vnet.id
output hubSubnetId string = gatewaySubnet.id
