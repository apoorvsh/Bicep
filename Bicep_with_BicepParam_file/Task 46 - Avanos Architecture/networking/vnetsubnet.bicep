
param vnetvalues object 
param nsgid string
//param vnetname string 


/*param sourcePeering string
param destinationPeering string
param gatewaySubnetName string
param gatewaySubnetPrefix string*/



resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01'  = {
   
   name: vnetvalues.name
   location: vnetvalues.location
   properties: {
     addressSpace: {
       addressPrefixes: [
        vnetvalues.addressprefix
       ]
     }
   }   
}

@batchSize(1)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, vnetvalues.count): {
   name: vnetvalues.subnetname[i]
   parent: vnet
   properties: {
     addressPrefix: vnetvalues.subnetprefix[i]
     networkSecurityGroup: i==2 ?  {
       id: nsgid
     } : null
     delegations: i==1 ?  [
       {
         name: vnetvalues.delegationName
         properties: {
          servicename: vnetvalues.serviceName
         } 
       }
     ] : null   
   }  
}]



/*resource SourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  '${hubVnetName}To${vnetname}'                                                       
  parent: vnet                                                                                                
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
       id: existingHubVnet.id
    }
  }
}


/*resource SourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  sourcePeering                                                         
  parent: vnet                                                                                                
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

/*resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  dependsOn: [
    vnet
    subnet
  ] 
  properties: {
     addressSpace: {
       addressPrefixes: [
          addressprefix
       ]
     }
  }    
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: gatewaySubnetName
  parent: vnet
  properties: {
    addressPrefix: gatewaySubnetPrefix
  }  
}





/*resource destinationToSourcePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name:  destinationPeering                                                         
  parent: hubVnet                                                                                              
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: vnet.id
    }
  }
}*/




output devvnet string = vnet.id
output devsubnet string = subnet[0].id
output deleSubnet string = subnet[1].id
output vmSubnet string = subnet[2].id
/*output hubVnet string = hubVnet.id
output gatewaySubnet string = gatewaySubnet.id*/


