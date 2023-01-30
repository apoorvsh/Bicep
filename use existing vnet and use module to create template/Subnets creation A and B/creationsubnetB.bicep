param subnetNameB string
param vnetName string
param subnetaddressPrefixB string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
}

resource subnetB 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: subnetNameB
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetaddressPrefixB
  }
}
