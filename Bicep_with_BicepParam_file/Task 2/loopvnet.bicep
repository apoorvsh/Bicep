param vnetName string
param vnetLocation string
param vnetAddressPrefix string
param subnetNames array
param subnetPrefixes array

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      for subnet in range(0,length(subnetNames)): {
        name: subnetNames[subnet]
        properties: {
          addressPrefix: subnetPrefixes[subnet]
        }
      }
    ]
  }
}
