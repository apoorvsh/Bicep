param vnetName string 
param vnetTagName object
param vnetAddress string 
param subnetName string  
param subnetAddress string 
param subnetName1 string
param subnetAddress1 string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2021-02-01'={
  name: subnetName1
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress1
  }
}
