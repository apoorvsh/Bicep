param values object

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: values.vnetName
  location: values.location
  properties: {
     addressSpace: {
       addressPrefixes: [
         values.addressprefix
       ]
     }
  }  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: values.subnetName
  parent: vnet 
  properties: {
     addressPrefix: values.subnetPrefix
  }   
}

output vnetId string = vnet.id
output subnetID string = subnet.id

