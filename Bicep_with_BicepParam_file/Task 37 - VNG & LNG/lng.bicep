param location string
param addressprefix string
param publicip string
param lngname string




resource lng 'Microsoft.Network/localNetworkGateways@2023-04-01' = {
  name: lngname
  location: location
  
  properties: {
    gatewayIpAddress: publicip
    localNetworkAddressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
  }
}
