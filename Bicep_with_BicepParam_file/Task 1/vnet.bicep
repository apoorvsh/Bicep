param vnetName string
param vnetLocation string
param vnetAddressPrefix string
param subnetname string
param subnetprefix string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name : subnetname
  parent: vnet
  properties: {
    addressPrefix: subnetprefix
  }

}





