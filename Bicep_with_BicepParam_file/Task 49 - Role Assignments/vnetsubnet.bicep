param values object 
param nsgid string
//param vnetname string 


/*param sourcePeering string
param destinationPeering string
param gatewaySubnetName string
param gatewaySubnetPrefix string*/



resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01'  = {
   
   name: values.name
   location: values.location
   properties: {
     addressSpace: {
       addressPrefixes: [
        values.addressprefix
       ]
     }
   }   
}

@batchSize(1)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, values.subnetCount): {
   name: values.subnetname[i]
   parent: vnet
   properties: {
     addressPrefix: values.subnetprefix[i]
     networkSecurityGroup: {
       id: nsgid
     }
      
   }  
}]

output adfSubnet  string = subnet[0].id
output storageSubnet string = subnet[1].id 
output vnetID string = vnet.id
