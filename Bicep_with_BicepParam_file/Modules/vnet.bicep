param vnetname string 
param location string 
param addressprefix string 

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
        addressprefix
       ]
     }
  }
}
