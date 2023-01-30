param subnetNameA string
param vnetName string
param subnetaddressPrefixA string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
}

resource subnetA 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: subnetNameA
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetaddressPrefixA
  }
}

